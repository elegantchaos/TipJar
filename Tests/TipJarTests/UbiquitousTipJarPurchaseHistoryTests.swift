import Foundation
import Testing
import TipJar
@testable import TipJarUbiquitousStore

@MainActor
@Suite("UbiquitousTipJarPurchaseHistory Tests")
struct UbiquitousTipJarPurchaseHistoryTests {
  @Test("history round-trips records through the ubiquitous store payload")
  func roundTrip() throws {
    let store = FakeUbiquitousStore()
    let history = UbiquitousTipJarPurchaseHistory(store: store)
    let purchase = TipJarPurchaseRecord(
      productID: "a",
      transactionID: "1",
      purchaseDate: Date(timeIntervalSince1970: 100),
      displayPrice: "£0.99"
    )

    try history.save(purchase)

    #expect(try history.containsTransaction(id: "1"))
    #expect(try history.loadRecent(limit: 1) == [purchase])
  }
}
