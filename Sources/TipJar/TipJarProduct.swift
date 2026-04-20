// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// StoreKit-independent Tip Jar product details.
public struct TipJarProduct: Sendable, Equatable, Identifiable {
  public let size: TipJarSize
  public let productID: String
  public let title: String
  public let displayPrice: String

  public init(
    size: TipJarSize,
    productID: String,
    title: String,
    displayPrice: String
  ) {
    self.size = size
    self.productID = productID
    self.title = title
    self.displayPrice = displayPrice
  }

  public var id: String { productID }
}
