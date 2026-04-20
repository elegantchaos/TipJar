// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

/// Status card shown while StoreKit products are being loaded.
struct TipJarLoadingStateCard: View {
  /// Standard spacing between the progress indicator and label.
  @ScaledMetric(relativeTo: .body) private var spacing = 12

  /// Interior padding for the loading card.
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
