// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import SwiftUI
import TipJar

struct TipJarProductsSection<C: TipJarServiceProvider & CommandCentre>: View {
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
