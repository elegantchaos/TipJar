// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Verified StoreKit transaction payload stored before finishing the transaction.
public struct VerifiedTipJarTransaction: Sendable, Equatable, Codable {
  public let size: TipJarSize
  public let productID: String
  public let transactionID: String
  public let purchaseDate: Date
  public let displayPrice: String

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
