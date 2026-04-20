import Testing
@testable import TipJar

@MainActor
@Suite("TipJarProduct Tests")
struct TipJarProductTests {
  @Test("product exposes its configured identifier")
  func idUsesProductID() {
    let product = TipJarProduct(
      size: .small,
      productID: "com.elegantchaos.actionstatus.tip.small",
      title: "Small Tip",
      displayPrice: "£0.99"
    )

    #expect(product.id == "com.elegantchaos.actionstatus.tip.small")
  }
}
