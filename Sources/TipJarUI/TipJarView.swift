// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import SwiftUI
import TipJar

/// Generic SwiftUI Tip Jar view driven by commands and a shared service.
public struct TipJarView<C: TipJarServiceProvider & CommandCentre>: View {
  @Environment(TipJarService.self) private var tipJarService

  @ScaledMetric(relativeTo: .body) private var contentPadding = 20
  @ScaledMetric(relativeTo: .body) private var sectionSpacing = 20

  private let commander: C

  public init(commander: C) {
    self.commander = commander
  }

  public var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: sectionSpacing) {
        TipJarIntroductionSection()

        TipJarProductsSection(
          commander: commander,
          products: tipJarService.products,
          state: tipJarService.state
        )

        if !recentPurchases.isEmpty {
          TipJarRecentPurchasesSection(purchases: recentPurchases)
        }

        if let errorMessage {
          TipJarErrorSection(message: errorMessage)
        }
      }
      .frame(maxWidth: 720, alignment: .leading)
      .padding(contentPadding)
    }
    .scrollBounceBehavior(.basedOnSize)
    .task {
      await loadContentIfNeeded()
    }
  }

  private var recentPurchases: [TipJarRecentPurchase] {
    tipJarService.recentPurchases.map { purchase in
      TipJarRecentPurchase(
        id: purchase.id,
        title: tipJarService.title(for: purchase),
        price: tipJarService.price(for: purchase),
        purchaseDate: purchase.purchaseDate
      )
    }
  }

  private var errorMessage: String? {
    guard case .failed(let message) = tipJarService.state else {
      return nil
    }

    return message
  }

  private func loadContentIfNeeded() async {
    tipJarService.loadRecentPurchases()

    guard tipJarService.products.isEmpty, tipJarService.state == .idle else {
      return
    }

    await tipJarService.loadProducts()
  }
}
