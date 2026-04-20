// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

/// Section that surfaces the current Tip Jar error message inside the sheet.
struct TipJarErrorSection: View {
  /// Vertical spacing between the section header and error body.
  @ScaledMetric(relativeTo: .body) private var spacing = 8

  /// Interior padding for the error message panel.
  @ScaledMetric(relativeTo: .body) private var panelPadding = 18

  /// User-visible error message to present.
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
