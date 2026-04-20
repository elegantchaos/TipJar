// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Store boundary for StoreKit-backed product loading and purchases.
public protocol TipJarStoreProtocol {
  /// Fetches Tip Jar products for the configured host application.
  func fetchProducts() async throws -> [TipJarProduct]

  /// Starts a purchase for the supplied tip size.
  func purchase(size: TipJarSize) async throws

  /// Stream of inbox transaction identifiers that should be persisted into history.
  var storedTransactionIDs: AsyncStream<String> { get }

  /// Lists every transaction currently persisted in the inbox.
  func listStoredTransactionIDs() throws -> [String]

  /// Loads one persisted verified transaction payload from the inbox.
  func loadStoredTransaction(id: String) throws -> VerifiedTipJarTransaction

  /// Deletes one inbox entry after it has been durably persisted elsewhere.
  func deleteStoredTransaction(id: String) throws
}
