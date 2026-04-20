import Testing
@testable import TipJar

@MainActor
@Suite("TipJarSize Tests")
struct TipJarSizeTests {
  @Test("configuration derives product identifiers from the app prefix")
  func productIDsAreDerived() {
    let configuration = TipJarConfiguration(productPrefix: "com.elegantchaos.actionstatus")

    #expect(configuration.productID(for: .small) == "com.elegantchaos.actionstatus.tip.small")
    #expect(configuration.productID(for: .medium) == "com.elegantchaos.actionstatus.tip.medium")
    #expect(configuration.productID(for: .large) == "com.elegantchaos.actionstatus.tip.large")
  }
}
