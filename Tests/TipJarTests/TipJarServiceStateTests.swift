import Testing
@testable import TipJar

@MainActor
@Suite("TipJarService.State Tests")
struct TipJarServiceStateTests {
  @Test("purchasing state reports that it is purchasing")
  func purchasingState() {
    #expect(TipJarService.State.purchasing(size: .small).isPurchasing)
    #expect(TipJarService.State.loaded.isPurchasing == false)
  }
}
