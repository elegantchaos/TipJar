// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import SwiftUI
import TipJar

/// Generic SwiftUI Tip Jar view driven by commands and a shared service.
public struct TipJarView<C: TipJarServiceProvider & CommandCentre>: View {
  /// Shared Tip Jar service injected by the host app.
  @Environment(TipJarService.self) private var tipJarService

  /// Outer padding for the sheet content.
  @ScaledMetric(relativeTo: .body) private var contentPadding = 20

  /// Vertical spacing between the major sections.
  @ScaledMetric(relativeTo: .body) private var sectionSpacing = 20

  /// Command centre used to execute Tip Jar commands.
  private let commander: C

  /// Creates a Tip Jar sheet view backed by the supplied command centre.
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

  /// Recent purchases mapped into UI-ready display values.
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

  /// Error message extracted from the current service state.
  private var errorMessage: String? {
    guard case .failed(let message) = tipJarService.state else {
      return nil
    }

    return message
  }

  /// Loads any persisted history and fetches products on first appearance.
  private func loadContentIfNeeded() async {
    tipJarService.loadRecentPurchases()

    guard tipJarService.products.isEmpty, tipJarService.state == .idle else {
      return
    }

    await tipJarService.loadProducts()
  }
}
