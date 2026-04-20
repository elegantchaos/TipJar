// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import SwiftUI

/// Shared section header styling used throughout the Tip Jar sheet.
struct TipJarSectionHeader: View {
  /// Section title text to render.
  let title: String

  var body: some View {
    Text(title)
      .font(.headline)
      .textCase(nil)
  }
}

/// UI-ready recent purchase values derived from persisted history and live products.
struct TipJarRecentPurchase: Identifiable {
  /// Stable identifier for list rendering.
  let id: String

  /// Display title for the purchase.
  let title: String

  /// Display price for the purchase.
  let price: String

  /// Purchase date shown in the recent purchases list.
  let purchaseDate: Date
}

/// Resolves Tip Jar-localized strings from the host application's main bundle.
func localized(_ key: String.LocalizationValue) -> String {
  String(localized: key, bundle: .main)
}
