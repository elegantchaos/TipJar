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
  private let commander: C

  public init(commander: C) {
    self.commander = commander
  }

  public var body: some View {
    Form {
      Section {
        Text(String(localized: "tip-jar.blurb", bundle: .module))
          .fixedSize(horizontal: false, vertical: true)
      }

      productsSection

      if !tipJarService.recentPurchases.isEmpty {
        recentPurchasesSection
      }

      if case .failed(let message) = tipJarService.state {
        Section(String(localized: "tip-jar.error", bundle: .module)) {
          Text(message)
            .foregroundStyle(.secondary)
        }
      }
    }
    .task {
      if tipJarService.products.isEmpty, tipJarService.state == .idle {
        await tipJarService.loadProducts()
      }
      tipJarService.loadRecentPurchases()
    }
  }

  @ViewBuilder private var productsSection: some View {
    Section {
      switch tipJarService.state {
        case .loadingProducts:
          HStack {
            Spacer()
            Text(String(localized: "tip-jar.loading", bundle: .module))
            ProgressView()
              .controlSize(.small)
            Spacer()
          }
          .foregroundStyle(.secondary)

        default:
          if tipJarService.products.isEmpty, case .loaded = tipJarService.state {
            Text(String(localized: "tip-jar.unavailable", bundle: .module))
              .foregroundStyle(.secondary)
          } else {
            ForEach(tipJarService.products) { product in
              commander.button(PurchaseTipCommand(size: product.size)) {
                HStack {
                  Text(product.title)
                  Spacer()
                  Text(product.displayPrice)
                    .foregroundStyle(.secondary)
                }
              }
              .disabled(tipJarService.state.isPurchasing)
            }
          }
      }
    } header: {
      Text(String(localized: "tip-jar.available", bundle: .module))
    } footer: {
      Text(String(localized: "tip-jar.footnote", bundle: .module))
    }
  }

  @ViewBuilder private var recentPurchasesSection: some View {
    Section(String(localized: "tip-jar.recent", bundle: .module)) {
      List(tipJarService.recentPurchases) { purchase in
        HStack {
          Text(tipJarService.title(for: purchase))
          Spacer()
          Text(tipJarService.price(for: purchase))
            .foregroundStyle(.secondary)
        }
      }
      .frame(height: 96)
    }
  }
}
