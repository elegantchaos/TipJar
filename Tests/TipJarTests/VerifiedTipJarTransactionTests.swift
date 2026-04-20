import Foundation
import Testing
@testable import TipJar

@MainActor
@Suite("VerifiedTipJarTransaction Tests")
struct VerifiedTipJarTransactionTests {
  @Test("payload preserves the selected size")
  func sizeIsStored() {
    let payload = VerifiedTipJarTransaction(
      size: .large,
      productID: "com.elegantchaos.actionstatus.tip.large",
      transactionID: "tx-1",
      purchaseDate: Date(timeIntervalSince1970: 1000),
      displayPrice: "£9.99"
    )

    #expect(payload.size == .large)
  }
}
