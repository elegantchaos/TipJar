import Foundation
import SwiftData
import Testing
import TipJar
import TipJarSwiftData

@MainActor
@Suite("SwiftDataTipJarPurchaseHistory Tests")
struct SwiftDataTipJarPurchaseHistoryTests {
  @Test("history saves and loads through SwiftData")
  func roundTrip() throws {
    let schema = Schema([PersistedTipJarPurchase.self])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: schema, configurations: [configuration])
    let history = SwiftDataTipJarPurchaseHistory(modelContext: ModelContext(container))
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
