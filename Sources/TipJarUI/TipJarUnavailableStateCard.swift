// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

/// Status card shown when the host app has no Tip Jar products available.
struct TipJarUnavailableStateCard: View {
  /// Interior padding for the unavailable-state card.
  @ScaledMetric(relativeTo: .body) private var panelPadding = 18

  var body: some View {
    Text(localized("tip-jar.unavailable"))
      .foregroundStyle(.secondary)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(panelPadding)
      .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
  }
}
