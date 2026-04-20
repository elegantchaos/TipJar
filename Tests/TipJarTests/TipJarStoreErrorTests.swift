import Testing
@testable import TipJar

@MainActor
@Suite("TipJarStoreError Tests")
struct TipJarStoreErrorTests {
  @Test("product not found surfaces the requested identifier")
  func productNotFoundDescription() {
    let error = TipJarStoreError.productNotFound(productID: "com.example.tip.small")
    #expect(error.errorDescription == "Couldn't find the tip product com.example.tip.small.")
  }
}
