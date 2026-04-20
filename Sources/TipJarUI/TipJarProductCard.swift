// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import SwiftUI
import TipJar

/// Card that renders one purchasable Tip Jar product as a command-backed button.
struct TipJarProductCard<C: TipJarServiceProvider & CommandCentre>: View {
  /// Command centre used to execute the purchase command.
  let commander: C

  /// Product to render.
  let product: TipJarProduct

  /// Whether any Tip Jar purchase is currently running.
  let isPurchasing: Bool

  /// Whether this card represents the active purchase.
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

/// Visual content for a Tip Jar product card.
private struct TipJarProductCardLabel: View {
  /// Product title shown to the user.
  let title: String

  /// Product price shown to the user.
  let price: String

  /// Whether the card should show active purchase styling.
  let isActivePurchase: Bool

  var body: some View {
    VStack(alignment: .leading) {
      HStack(alignment: .firstTextBaseline) {
        Text(title)
          .font(.headline)
          .foregroundStyle(.primary)
          .lineLimit(2)

        Spacer()

        if isActivePurchase {
          ProgressView()
            .controlSize(.small)
        }
      }

      Text(price)
        .font(.title3.weight(.semibold))
        .foregroundStyle(.tint)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding()
    .background(backgroundStyle, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    .overlay {
      RoundedRectangle(cornerRadius: 18, style: .continuous)
        .strokeBorder(.quaternary)
    }
    .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
  }

  /// Background styling that emphasizes the currently active purchase.
  private var backgroundStyle: AnyShapeStyle {
    if isActivePurchase {
      return AnyShapeStyle(.tint.opacity(0.14))
    }

    return AnyShapeStyle(.regularMaterial)
  }
}

// TODO: add previews
