// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

/// Persistence boundary for durable purchase history.
@MainActor
public protocol TipJarPurchaseHistory: Sendable {
  /// Returns whether a transaction has already been persisted.
  func containsTransaction(id: String) throws -> Bool

  /// Persists a purchase record if it is not already present.
  func save(_ purchase: TipJarPurchaseRecord) throws

  /// Loads recent purchases ordered by recency according to the concrete store.
  func loadRecent(limit: Int) throws -> [TipJarPurchaseRecord]
}
