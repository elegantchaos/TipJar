import Foundation
@testable import TipJar

final class MockTipJarStore: TipJarStoreProtocol {
  var productsToReturn: [TipJarProduct] = []
  var errorToThrow: Error?
  var purchasedSizes: [TipJarSize] = []
  var storedTransactions: [String: VerifiedTipJarTransaction] = [:]
  var transactionToStoreOnPurchase: VerifiedTipJarTransaction?
  private var continuations: [UUID: AsyncStream<String>.Continuation] = [:]

  var storedTransactionIDs: AsyncStream<String> {
    AsyncStream { continuation in
      let id = UUID()
      continuations[id] = continuation
    }
  }

  func fetchProducts() async throws -> [TipJarProduct] {
    if let errorToThrow {
      throw errorToThrow
    }
    return productsToReturn
  }

  func purchase(size: TipJarSize) async throws {
    if let errorToThrow {
      throw errorToThrow
    }
    purchasedSizes.append(size)

    if let transactionToStoreOnPurchase {
      storedTransactions[transactionToStoreOnPurchase.transactionID] = transactionToStoreOnPurchase
    }
  }

  func listStoredTransactionIDs() throws -> [String] {
    if let errorToThrow {
      throw errorToThrow
    }
    return Array(storedTransactions.keys).sorted()
  }

  func loadStoredTransaction(id: String) throws -> VerifiedTipJarTransaction {
    if let errorToThrow {
      throw errorToThrow
    }
    guard let transaction = storedTransactions[id] else {
      throw TipJarStoreError.storageUnavailable
    }
    return transaction
  }

  func deleteStoredTransaction(id: String) throws {
    if let errorToThrow {
      throw errorToThrow
    }
    storedTransactions.removeValue(forKey: id)
  }

  func simulateStoredTransaction(_ transaction: VerifiedTipJarTransaction) {
    storedTransactions[transaction.transactionID] = transaction
    for continuation in continuations.values {
      continuation.yield(transaction.transactionID)
    }
  }
}
