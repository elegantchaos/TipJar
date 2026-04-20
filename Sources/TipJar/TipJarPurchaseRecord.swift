// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Canonical persisted purchase record.
public struct TipJarPurchaseRecord: Sendable, Equatable, Codable, Identifiable {
  /// Purchased StoreKit product identifier.
  public let productID: String

  /// Stable StoreKit transaction identifier.
  public let transactionID: String

  /// Purchase date reported by StoreKit.
  public let purchaseDate: Date

  /// Localized price captured for display in recent purchases.
  public let displayPrice: String

  /// Creates a persisted record that matches the package's canonical storage shape.
  public init(
    productID: String,
    transactionID: String,
    purchaseDate: Date,
    displayPrice: String
  ) {
    self.productID = productID
    self.transactionID = transactionID
    self.purchaseDate = purchaseDate
    self.displayPrice = displayPrice
  }

  /// Stable identifier used for list rendering and deduplication.
  public var id: String { transactionID }
}
