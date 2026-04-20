// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// Errors thrown by Tip Jar store operations.
public enum TipJarStoreError: Error, LocalizedError, Equatable {
  case storeKitUnavailable
  case storageUnavailable
  case productNotFound(productID: String)
  case failedVerification
  case userCancelled
  case pending

  public var errorDescription: String? {
    switch self {
      case .storeKitUnavailable:
        "StoreKit is unavailable on this platform."
      case .storageUnavailable:
        "Tip Jar transaction storage is unavailable."
      case .productNotFound(let productID):
        "Couldn't find the tip product \(productID)."
      case .failedVerification:
        "The purchase could not be verified."
      case .userCancelled:
        "The purchase was cancelled."
      case .pending:
        "The purchase is pending."
    }
  }
}
