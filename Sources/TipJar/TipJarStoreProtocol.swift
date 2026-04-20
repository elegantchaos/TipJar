// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Store boundary for StoreKit-backed product loading and purchases.
public protocol TipJarStoreProtocol {
  func fetchProducts() async throws -> [TipJarProduct]
  func purchase(size: TipJarSize) async throws
  var storedTransactionIDs: AsyncStream<String> { get }
  func listStoredTransactionIDs() throws -> [String]
  func loadStoredTransaction(id: String) throws -> VerifiedTipJarTransaction
  func deleteStoredTransaction(id: String) throws
}
