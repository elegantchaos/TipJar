// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Logger

private let tipJarStoreChannel = Channel("TipJarStore")

/// Stub implementation used on platforms without StoreKit support.
public struct StubTipJarStore: TipJarStoreProtocol {
  public init() {
  }

  public var storedTransactionIDs: AsyncStream<String> {
    AsyncStream { continuation in
      continuation.finish()
    }
  }

  public func fetchProducts() async throws -> [TipJarProduct] {
    throw TipJarStoreError.storeKitUnavailable
  }

  public func purchase(size: TipJarSize) async throws {
    throw TipJarStoreError.storeKitUnavailable
  }

  public func listStoredTransactionIDs() throws -> [String] {
    []
  }

  public func loadStoredTransaction(id: String) throws -> VerifiedTipJarTransaction {
    throw TipJarStoreError.storageUnavailable
  }

  public func deleteStoredTransaction(id: String) throws {
    throw TipJarStoreError.storageUnavailable
  }
}

#if canImport(StoreKit)
  import StoreKit

  public struct TipJarStore: TipJarStoreProtocol {
    private let configuration: TipJarConfiguration
    private let inbox: TipJarTransactionInbox
    private let streamState = StreamState()

    public init(configuration: TipJarConfiguration) {
      self.configuration = configuration
      self.inbox = (try? TipJarTransactionInbox(applicationID: configuration.productPrefix)) ?? .disabled
    }

    public var storedTransactionIDs: AsyncStream<String> {
      let streamState = self.streamState
      return AsyncStream { continuation in
        let token = UUID()
        Task {
          await streamState.add(continuation, id: token)
        }
        continuation.onTermination = { _ in
          Task {
            await streamState.remove(token)
          }
        }
      }
    }

    public func fetchProducts() async throws -> [TipJarProduct] {
      let ids = TipJarSize.allCases.map(configuration.productID(for:))
      let products = try await Product.products(for: ids)
      return products.compactMap { product in
        guard let size = configuration.size(for: product.id) else {
          return nil
        }

        return TipJarProduct(
          size: size,
          productID: product.id,
          title: product.displayName,
          displayPrice: product.displayPrice
        )
      }
      .sorted { lhs, rhs in
        guard let leftIndex = TipJarSize.allCases.firstIndex(of: lhs.size),
              let rightIndex = TipJarSize.allCases.firstIndex(of: rhs.size)
        else {
          return lhs.productID < rhs.productID
        }

        return leftIndex < rightIndex
      }
    }

    public func purchase(size: TipJarSize) async throws {
      let productID = configuration.productID(for: size)
      let products = try await Product.products(for: [productID])
      guard let product = products.first else {
        throw TipJarStoreError.productNotFound(productID: productID)
      }

      let result = try await product.purchase()
      switch result {
        case .success(let verification):
          let transaction = try verifiedTransaction(from: verification)
          try await storeAndFinish(transaction: transaction, displayPrice: product.displayPrice)
        case .userCancelled:
          throw TipJarStoreError.userCancelled
        case .pending:
          throw TipJarStoreError.pending
        @unknown default:
          throw TipJarStoreError.failedVerification
      }
    }

    public func listStoredTransactionIDs() throws -> [String] {
      try inbox.listIDs()
    }

    public func loadStoredTransaction(id: String) throws -> VerifiedTipJarTransaction {
      try inbox.load(id: id)
    }

    public func deleteStoredTransaction(id: String) throws {
      try inbox.delete(id: id)
    }

    private func verifiedTransaction(from result: VerificationResult<Transaction>) throws -> Transaction {
      switch result {
        case .verified(let transaction):
          transaction
        case .unverified:
          throw TipJarStoreError.failedVerification
      }
    }

    private func storeAndFinish(transaction: Transaction, displayPrice: String?) async throws {
      try await storeAndFinish(
        transaction: transaction,
        displayPrice: displayPrice,
        configuration: configuration
      )
    }

    private func storeAndFinish(
      transaction: Transaction,
      displayPrice: String?,
      configuration: TipJarConfiguration
    ) async throws {
      let payload = try Self.makePayload(
        transaction: transaction,
        displayPrice: displayPrice,
        configuration: configuration
      )
      let id = try inbox.store(payload)
      await streamState.yield(id)
      await transaction.finish()
    }

    private static func makePayload(
      transaction: Transaction,
      displayPrice: String?,
      configuration: TipJarConfiguration
    ) throws -> VerifiedTipJarTransaction {
      guard let size = configuration.size(for: transaction.productID) else {
        throw TipJarStoreError.failedVerification
      }

      return VerifiedTipJarTransaction(
        size: size,
        productID: transaction.productID,
        transactionID: String(transaction.id),
        purchaseDate: transaction.purchaseDate,
        displayPrice: displayPrice ?? ""
      )
    }

  }

  actor StreamState {
    private var continuations: [UUID: AsyncStream<String>.Continuation] = [:]

    func add(_ continuation: AsyncStream<String>.Continuation, id: UUID) {
      continuations[id] = continuation
    }

    func remove(_ id: UUID) {
      continuations.removeValue(forKey: id)
    }

    func yield(_ value: String) {
      for continuation in continuations.values {
        continuation.yield(value)
      }
    }
  }

#else
  public typealias TipJarStore = StubTipJarStore
#endif
