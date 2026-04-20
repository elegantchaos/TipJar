// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import SwiftUI
import TipJar

/// Section that renders the fixed set of Tip Jar products and their loading states.
struct TipJarProductsSection<C: TipJarServiceProvider & CommandCentre>: View {
  /// Command centre used to execute purchase commands.
  let commander: C

  /// Products currently available for purchase.
  let products: [TipJarProduct]

  /// Current service state used to render loading and purchasing UI.
  let state: TipJarService.State

  var body: some View {
    VStack(alignment: .leading) {
      TipJarSectionHeader(title: localized("tip-jar.available"))

      if showsLoadingState {
        TipJarLoadingStateCard()
      } else if products.isEmpty {
        TipJarUnavailableStateCard()
      } else {
        LazyVGrid(
          columns: [GridItem(.adaptive(minimum: 220), alignment: .top)],
          alignment: .leading
          
        ) {
          ForEach(products) { product in
            TipJarProductCard(
              commander: commander,
              product: product,
              isPurchasing: state.isPurchasing,
              isActivePurchase: activePurchaseSize == product.size
            )
          }
        }
      }
    }
  }

  /// Returns whether the section should show the loading placeholder.
  private var showsLoadingState: Bool {
    switch state {
      case .idle, .loadingProducts:
        true
      case .loaded, .purchasing, .failed:
        false
    }
  }

  /// Returns the size of the currently active purchase, if any.
  private var activePurchaseSize: TipJarSize? {
    guard case .purchasing(let size) = state else {
      return nil
    }

    return size
  }
}
