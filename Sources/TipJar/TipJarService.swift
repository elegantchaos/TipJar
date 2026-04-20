// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Logger
import Observation

private let tipJarChannel = Channel("TipJar")

/// UI-facing Tip Jar orchestration service.
@MainActor
@Observable
public final class TipJarService {
  /// Current load and purchase state.
  public enum State: Sendable, Equatable {
    case idle
    case loadingProducts
    case loaded
    case purchasing(size: TipJarSize)
    case failed(message: String)

    public var isPurchasing: Bool {
      if case .purchasing = self {
        return true
      }
      return false
    }
  }

  private let configuration: TipJarConfiguration
  private let store: any TipJarStoreProtocol
  private let purchaseHistory: any TipJarPurchaseHistory
  private var listenerTask: Task<Void, Never>?
  private var didAttemptRecovery = false

  public private(set) var state: State = .idle
  public private(set) var products: [TipJarProduct] = []
  public private(set) var recentPurchases: [TipJarPurchaseRecord] = []

  public init(
    configuration: TipJarConfiguration,
    purchaseHistory: any TipJarPurchaseHistory,
    store: (any TipJarStoreProtocol)? = nil
  ) {
    self.configuration = configuration
    self.purchaseHistory = purchaseHistory
    self.store = store ?? TipJarStore(configuration: configuration)
    startListeningForStoredTransactions()
  }

  /// Loads products and any previously persisted purchase history.
  public func loadProducts() async {
    state = .loadingProducts

    do {
      products = try await store.fetchProducts()
      state = .loaded
      loadRecentPurchases()
      await recoverStoredTransactionsIfNeeded()
    } catch {
      tipJarChannel.log("loadProducts failed: \(error)")
      state = .failed(message: error.localizedDescription)
    }
  }

  /// Loads recent purchases from the configured history store.
  public func loadRecentPurchases(limit: Int = 10) {
    do {
      recentPurchases = try purchaseHistory.loadRecent(limit: limit)
        .sorted { $0.purchaseDate > $1.purchaseDate }
    } catch {
      tipJarChannel.log("loadRecentPurchases failed: \(error)")
      state = .failed(message: error.localizedDescription)
    }
  }

  /// Purchases the specified tip size.
  public func purchase(_ size: TipJarSize) async throws {
    state = .purchasing(size: size)

    do {
      try await store.purchase(size: size)
      state = .loaded
    } catch {
      tipJarChannel.log("purchase failed: \(error)")
      state = .failed(message: error.localizedDescription)
      throw error
    }
  }

  /// Returns the configured product identifier for a size.
  public func productID(for size: TipJarSize) -> String {
    configuration.productID(for: size)
  }

  /// Returns the product title to show for a previously persisted purchase.
  public func title(for purchase: TipJarPurchaseRecord) -> String {
    if let product = products.first(where: { $0.productID == purchase.productID }) {
      return product.title
    }

    if let size = configuration.size(for: purchase.productID) {
      return size.fallbackTitle
    }

    return "Unknown Tip"
  }

  /// Returns the display price to show for a previously persisted purchase.
  public func price(for purchase: TipJarPurchaseRecord) -> String {
    if purchase.displayPrice.isEmpty,
       let product = products.first(where: { $0.productID == purchase.productID })
    {
      return product.displayPrice
    }

    return purchase.displayPrice
  }

  /// Creates a preview-friendly service with stub state.
  public static func preview(
    configuration: TipJarConfiguration,
    store: any TipJarStoreProtocol,
    purchaseHistory: any TipJarPurchaseHistory
  ) -> TipJarService {
    TipJarService(
      configuration: configuration,
      purchaseHistory: purchaseHistory,
      store: store
    )
  }

  private func startListeningForStoredTransactions() {
    listenerTask?.cancel()
    listenerTask = Task { [weak self] in
      guard let self else { return }

      for await id in store.storedTransactionIDs {
        await self.processStoredTransaction(id: id)
      }
    }
  }

  private func recoverStoredTransactionsIfNeeded() async {
    guard !didAttemptRecovery else { return }
    didAttemptRecovery = true

    do {
      for id in try store.listStoredTransactionIDs() {
        await processStoredTransaction(id: id)
      }
    } catch {
      tipJarChannel.log("recoverStoredTransactions failed: \(error)")
    }
  }

  private func processStoredTransaction(id: String) async {
    do {
      var verified = try store.loadStoredTransaction(id: id)

      if verified.displayPrice.isEmpty,
         let product = products.first(where: { $0.productID == verified.productID })
      {
        verified = VerifiedTipJarTransaction(
          size: verified.size,
          productID: verified.productID,
          transactionID: verified.transactionID,
          purchaseDate: verified.purchaseDate,
          displayPrice: product.displayPrice
        )
      }

      let record = TipJarPurchaseRecord(
        productID: verified.productID,
        transactionID: verified.transactionID,
        purchaseDate: verified.purchaseDate,
        displayPrice: verified.displayPrice
      )

      if try persist(record) {
        try store.deleteStoredTransaction(id: id)
      }
    } catch {
      tipJarChannel.log("processStoredTransaction failed: \(error)")
    }
  }

  private func persist(_ record: TipJarPurchaseRecord) throws -> Bool {
    let exists = try purchaseHistory.containsTransaction(id: record.transactionID)
    if !exists {
      try purchaseHistory.save(record)
    }

    loadRecentPurchases()
    return true
  }
}
