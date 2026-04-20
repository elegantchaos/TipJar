// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

/// Introductory panel that explains what Tip Jar purchases are for.
struct TipJarIntroductionSection: View {
  /// Icon size scaled with Dynamic Type.
  @ScaledMetric(relativeTo: .body) private var iconSize = 44

  var body: some View {
    HStack(alignment: .top) {
      Image(systemName: "heart.circle.fill")
        .font(.system(size: iconSize))
        .foregroundStyle(.tint)
        .accessibilityHidden(true)

      VStack(alignment: .leading) {
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
    .padding()
    .background(.quaternary, in: tipJarCardShape)
  }
}
