// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Canonical persisted purchase record.
public struct TipJarPurchaseRecord: Sendable, Equatable, Codable, Identifiable {
  public let productID: String
  public let transactionID: String
  public let purchaseDate: Date
  public let displayPrice: String

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

  public var id: String { transactionID }
}
