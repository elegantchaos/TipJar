// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Host-supplied configuration for deriving Tip Jar product identifiers.
public struct TipJarConfiguration: Sendable, Equatable {
  /// Prefix used to derive StoreKit product identifiers for the host app.
  public let productPrefix: String

  /// Creates a configuration that derives product identifiers from the supplied prefix.
  public init(productPrefix: String) {
    self.productPrefix = productPrefix
  }

  /// Returns the configured product identifier for a tip size.
  public func productID(for size: TipJarSize) -> String {
    "\(productPrefix).tip.\(size.rawValue)"
  }

  /// Returns the tip size associated with a configured product identifier.
  public func size(for productID: String) -> TipJarSize? {
    TipJarSize.allCases.first(where: { self.productID(for: $0) == productID })
  }
}
