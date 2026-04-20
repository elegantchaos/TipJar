// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

struct TipJarIntroductionSection: View {
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
