// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 24/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

/// Volatile purchase history store that keeps records in memory for the lifetime of the service.
@MainActor
public final class InMemoryTipJarPurchaseHistory: TipJarPurchaseHistory {
  /// Purchases currently held by the store.
  public private(set) var purchases: [TipJarPurchaseRecord]

  /// Creates an in-memory history seeded with existing purchases.
  public init(purchases: [TipJarPurchaseRecord] = []) {
    self.purchases = purchases
  }

  /// Returns whether the supplied transaction identifier has already been saved.
  public func containsTransaction(id: String) throws -> Bool {
    purchases.contains(where: { $0.transactionID == id })
  }

  /// Saves the supplied purchase unless the transaction is already present.
  public func save(_ purchase: TipJarPurchaseRecord) throws {
    guard purchases.contains(where: { $0.transactionID == purchase.transactionID }) == false else {
      return
    }

    purchases.append(purchase)
  }

  /// Loads recent purchases from memory, returning at most the requested number of records.
  public func loadRecent(limit: Int) throws -> [TipJarPurchaseRecord] {
    Array(purchases.sorted { $0.purchaseDate > $1.purchaseDate }.prefix(limit))
  }
}
