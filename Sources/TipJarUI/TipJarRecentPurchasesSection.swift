// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

/// Section that renders persisted recent purchases once history exists.
struct TipJarRecentPurchasesSection: View {
  /// Standard spacing used within the section.
  @ScaledMetric(relativeTo: .body) private var spacing = 12

  /// Recent purchases already mapped into UI-ready values.
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

/// Row that renders one persisted recent purchase.
private struct TipJarRecentPurchaseRow: View {
  /// Horizontal spacing between the title block and trailing price.
  @ScaledMetric(relativeTo: .body) private var spacing = 8

  /// Interior padding for the row.
  @ScaledMetric(relativeTo: .body) private var rowPadding = 14

  /// Purchase entry to present.
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
