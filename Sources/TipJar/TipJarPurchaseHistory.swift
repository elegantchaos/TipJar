// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

/// Persistence boundary for durable purchase history.
@MainActor
public protocol TipJarPurchaseHistory: Sendable {
  func containsTransaction(id: String) throws -> Bool
  func save(_ purchase: TipJarPurchaseRecord) throws
  func loadRecent(limit: Int) throws -> [TipJarPurchaseRecord]
}
