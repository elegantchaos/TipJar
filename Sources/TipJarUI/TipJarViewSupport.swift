// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import SwiftUI

struct TipJarSectionHeader: View {
  let title: String

  var body: some View {
    Text(title)
      .font(.headline)
      .textCase(nil)
  }
}

struct TipJarRecentPurchase: Identifiable {
  let id: String
  let title: String
  let price: String
  let purchaseDate: Date
}

func localized(_ key: String.LocalizationValue) -> String {
  String(localized: key, bundle: .main)
}
