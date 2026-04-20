// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Supported tip sizes in v1 of the package.
public enum TipJarSize: String, Sendable, CaseIterable, Codable {
  case small
  case medium
  case large

  public var fallbackTitle: String {
    switch self {
      case .small:
        "Small Tip"
      case .medium:
        "Medium Tip"
      case .large:
        "Large Tip"
    }
  }
}
