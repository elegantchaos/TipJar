// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Verified StoreKit transaction payload stored before finishing the transaction.
public struct VerifiedTipJarTransaction: Sendable, Equatable, Codable {
  /// Fixed package-defined tip size derived from the product identifier.
  public let size: TipJarSize

  /// Purchased StoreKit product identifier.
  public let productID: String

  /// Stable StoreKit transaction identifier.
  public let transactionID: String

  /// Purchase date reported by StoreKit.
  public let purchaseDate: Date

  /// Localized price captured at purchase time when available.
  public let displayPrice: String

  /// Creates a persisted representation of a verified StoreKit transaction.
  public init(
    size: TipJarSize,
    productID: String,
    transactionID: String,
    purchaseDate: Date,
    displayPrice: String
  ) {
    self.size = size
    self.productID = productID
    self.transactionID = transactionID
    self.purchaseDate = purchaseDate
    self.displayPrice = displayPrice
  }
}
