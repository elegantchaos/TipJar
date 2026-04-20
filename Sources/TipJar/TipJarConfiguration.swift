// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Host-supplied configuration for deriving Tip Jar product identifiers.
public struct TipJarConfiguration: Sendable, Equatable {
  public let productPrefix: String

  public init(productPrefix: String) {
    self.productPrefix = productPrefix
  }

  public func productID(for size: TipJarSize) -> String {
    "\(productPrefix).tip.\(size.rawValue)"
  }

  public func size(for productID: String) -> TipJarSize? {
    TipJarSize.allCases.first(where: { self.productID(for: $0) == productID })
  }
}
