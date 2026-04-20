// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

/// Section that surfaces the current Tip Jar error message inside the sheet.
struct TipJarErrorSection: View {
  /// User-visible error message to present.
  let message: String

  var body: some View {
    VStack(alignment: .leading) {
      TipJarSectionHeader(title: localized("tip-jar.error"))

      Text(message)
        .font(.body)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.red.opacity(0.08), in: tipJarCardShape)
    }
  }
}
