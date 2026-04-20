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

    /// Returns whether a purchase is currently in flight.
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

  /// Background task that listens for persisted transaction inbox updates.
  private var listenerTask: Task<Void, Never>?

  /// Guards one-time recovery of previously persisted inbox entries.
  private var didAttemptRecovery = false

  /// Current product-loading and purchase state.
  public private(set) var state: State = .idle

  /// Available tip products resolved from StoreKit.
  public private(set) var products: [TipJarProduct] = []

  /// Recent persisted purchase history shown in the UI.
  public private(set) var recentPurchases: [TipJarPurchaseRecord] = []

  /// Creates a service backed by StoreKit and a concrete purchase history store.
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
      await processStoredTransactions()
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

  /// Starts listening for transaction identifiers emitted after inbox persistence.
  private func startListeningForStoredTransactions() {
    listenerTask?.cancel()
    listenerTask = Task { [weak self] in
      guard let self else { return }

      for await id in store.storedTransactionIDs {
        await self.processStoredTransaction(id: id)
      }
    }
  }

  /// Processes any inbox entries left behind from a previous launch once per service lifetime.
  private func recoverStoredTransactionsIfNeeded() async {
    guard !didAttemptRecovery else { return }
    didAttemptRecovery = true
    await processStoredTransactions()
  }

  /// Drains every currently persisted inbox entry into durable purchase history.
  private func processStoredTransactions() async {
    do {
      for id in try store.listStoredTransactionIDs() {
        await processStoredTransaction(id: id)
      }
    } catch {
      tipJarChannel.log("recoverStoredTransactions failed: \(error)")
    }
  }

  /// Maps a persisted verified transaction into purchase history and clears the inbox entry on success.
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

  /// Persists a purchase record if needed, then refreshes the in-memory recent list.
  private func persist(_ record: TipJarPurchaseRecord) throws -> Bool {
    let exists = try purchaseHistory.containsTransaction(id: record.transactionID)
    if !exists {
      try purchaseHistory.save(record)
    }

    loadRecentPurchases()
    return true
  }
}
