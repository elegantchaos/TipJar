import Foundation
import Testing
import TipJar
@testable import TipJarLocalStore

@MainActor
@Suite("LocalTipJarPurchaseHistory Tests")
struct LocalTipJarPurchaseHistoryTests {
  @Test("history sorts recent purchases newest first")
  func loadsRecentPurchases() throws {
    let fileURL = FileManager.default.temporaryDirectory
      .appending(path: UUID().uuidString, directoryHint: .notDirectory)
    let history = LocalTipJarPurchaseHistory(fileURL: fileURL)

    try history.save(
      TipJarPurchaseRecord(
        productID: "a",
        transactionID: "1",
        purchaseDate: Date(timeIntervalSince1970: 100),
        displayPrice: "£0.99"
      )
    )
    try history.save(
      TipJarPurchaseRecord(
        productID: "b",
        transactionID: "2",
        purchaseDate: Date(timeIntervalSince1970: 200),
        displayPrice: "£2.99"
      )
    )

    let recent = try history.loadRecent(limit: 2)
    #expect(recent.map(\.transactionID) == ["2", "1"])
  }
}
