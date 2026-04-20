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

private struct TipJarIntroductionSection: View {
  @ScaledMetric(relativeTo: .body) private var spacing = 12
  @ScaledMetric(relativeTo: .body) private var iconSize = 44
  @ScaledMetric(relativeTo: .body) private var panelPadding = 18

  var body: some View {
    HStack(alignment: .top, spacing: spacing) {
      Image(systemName: "heart.circle.fill")
        .font(.system(size: iconSize))
        .foregroundStyle(.tint)
        .accessibilityHidden(true)

      VStack(alignment: .leading, spacing: spacing) {
        Text(localized("tip-jar.blurb"))
          .font(.body)
          .fixedSize(horizontal: false, vertical: true)

        Text(localized("tip-jar.footnote"))
          .font(.footnote)
          .foregroundStyle(.secondary)
          .fixedSize(horizontal: false, vertical: true)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(panelPadding)
    .background(.quaternary, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
  }
}

private struct TipJarProductsSection<C: TipJarServiceProvider & CommandCentre>: View {
  @ScaledMetric(relativeTo: .body) private var spacing = 12

  let commander: C
  let products: [TipJarProduct]
  let state: TipJarService.State

  var body: some View {
    VStack(alignment: .leading, spacing: spacing) {
      TipJarSectionHeader(title: localized("tip-jar.available"))

      if showsLoadingState {
        TipJarLoadingStateCard()
      } else if products.isEmpty {
        TipJarUnavailableStateCard()
      } else {
        LazyVGrid(
          columns: [GridItem(.adaptive(minimum: 220), spacing: spacing, alignment: .top)],
          alignment: .leading,
          spacing: spacing
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

  private var showsLoadingState: Bool {
    switch state {
      case .idle, .loadingProducts:
        true
      case .loaded, .purchasing, .failed:
        false
    }
  }

  private var activePurchaseSize: TipJarSize? {
    guard case .purchasing(let size) = state else {
      return nil
    }

    return size
  }
}

private struct TipJarProductCard<C: TipJarServiceProvider & CommandCentre>: View {
  let commander: C
  let product: TipJarProduct
  let isPurchasing: Bool
  let isActivePurchase: Bool

  var body: some View {
    commander.button(PurchaseTipCommand(size: product.size)) {
      TipJarProductCardLabel(
        title: product.title,
        price: product.displayPrice,
        isActivePurchase: isActivePurchase
      )
    }
      .buttonStyle(.plain)
      .disabled(isPurchasing)
      .accessibilityHint(Text(localized("tip-jar.footnote")))
  }
}

private struct TipJarProductCardLabel: View {
  @ScaledMetric(relativeTo: .body) private var spacing = 10
  @ScaledMetric(relativeTo: .body) private var panelPadding = 16

  let title: String
  let price: String
  let isActivePurchase: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: spacing) {
      HStack(alignment: .firstTextBaseline, spacing: spacing) {
        Text(title)
          .font(.headline)
          .foregroundStyle(.primary)
          .lineLimit(2)

        Spacer(minLength: 0)

        if isActivePurchase {
          ProgressView()
            .controlSize(.small)
        }
      }

      Text(price)
        .font(.title3.weight(.semibold))
        .foregroundStyle(.tint)

      Spacer(minLength: 0)
    }
    .frame(maxWidth: .infinity, minHeight: 104, alignment: .leading)
    .padding(panelPadding)
    .background(backgroundStyle, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    .overlay {
      RoundedRectangle(cornerRadius: 18, style: .continuous)
        .strokeBorder(.quaternary)
    }
    .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
  }

  private var backgroundStyle: AnyShapeStyle {
    if isActivePurchase {
      return AnyShapeStyle(.tint.opacity(0.14))
    }

    return AnyShapeStyle(.regularMaterial)
  }
}

private struct TipJarLoadingStateCard: View {
  @ScaledMetric(relativeTo: .body) private var spacing = 12
  @ScaledMetric(relativeTo: .body) private var panelPadding = 18

  var body: some View {
    HStack(spacing: spacing) {
      ProgressView()
      Text(localized("tip-jar.loading"))
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(panelPadding)
    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
  }
}

private struct TipJarUnavailableStateCard: View {
  @ScaledMetric(relativeTo: .body) private var panelPadding = 18

  var body: some View {
    Text(localized("tip-jar.unavailable"))
      .foregroundStyle(.secondary)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(panelPadding)
      .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
  }
}

private struct TipJarRecentPurchasesSection: View {
  @ScaledMetric(relativeTo: .body) private var spacing = 12

  let purchases: [TipJarRecentPurchase]

  var body: some View {
    VStack(alignment: .leading, spacing: spacing) {
      TipJarSectionHeader(title: localized("tip-jar.recent"))

      VStack(spacing: 0) {
        ForEach(purchases) { purchase in
          TipJarRecentPurchaseRow(purchase: purchase)

          if purchase.id != purchases.last?.id {
            Divider()
          }
        }
      }
      .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
      .overlay {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
          .strokeBorder(.quaternary)
      }
    }
  }
}

private struct TipJarRecentPurchaseRow: View {
  @ScaledMetric(relativeTo: .body) private var spacing = 8
  @ScaledMetric(relativeTo: .body) private var rowPadding = 14

  let purchase: TipJarRecentPurchase

  var body: some View {
    HStack(alignment: .top, spacing: spacing) {
      VStack(alignment: .leading, spacing: 4) {
        Text(purchase.title)
          .font(.headline)

        Text(purchase.purchaseDate, format: .dateTime.year().month(.abbreviated).day())
          .font(.footnote)
          .foregroundStyle(.secondary)
      }

      Spacer(minLength: 0)

      Text(purchase.price)
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(rowPadding)
  }
}

private struct TipJarErrorSection: View {
  @ScaledMetric(relativeTo: .body) private var spacing = 8
  @ScaledMetric(relativeTo: .body) private var panelPadding = 18

  let message: String

  var body: some View {
    VStack(alignment: .leading, spacing: spacing) {
      TipJarSectionHeader(title: localized("tip-jar.error"))

      Text(message)
        .font(.body)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(panelPadding)
        .background(.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
  }
}

private struct TipJarSectionHeader: View {
  let title: String

  var body: some View {
    Text(title)
      .font(.headline)
      .textCase(nil)
  }
}

private struct TipJarRecentPurchase: Identifiable {
  let id: String
  let title: String
  let price: String
  let purchaseDate: Date
}

private func localized(_ key: String.LocalizationValue) -> String {
  String(localized: key, bundle: .main)
}
