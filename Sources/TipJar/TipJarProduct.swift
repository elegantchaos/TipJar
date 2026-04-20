// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// StoreKit-independent Tip Jar product details.
public struct TipJarProduct: Sendable, Equatable, Identifiable {
  /// Fixed package-defined tip size for the product.
  public let size: TipJarSize

  /// Full StoreKit product identifier.
  public let productID: String

  /// User-visible product title resolved from StoreKit.
  public let title: String

  /// User-visible localized price string.
  public let displayPrice: String

  /// Creates a StoreKit-independent product description for UI and persistence logic.
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

  /// Stable identifier used by SwiftUI lists and grids.
  public var id: String { productID }
}
