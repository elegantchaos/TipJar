import Foundation
import Testing
@testable import TipJar

@MainActor
@Suite("TipJarTransactionInbox Tests")
struct TipJarTransactionInboxTests {
  @Test("stored transactions round-trip through the inbox")
  func roundTrip() throws {
    let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString, directoryHint: .isDirectory)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    let inbox = TipJarTransactionInbox(directoryURL: directory)
    let transaction = VerifiedTipJarTransaction(
      size: .small,
      productID: "com.elegantchaos.actionstatus.tip.small",
      transactionID: "tx-123",
      purchaseDate: Date(timeIntervalSince1970: 1000),
      displayPrice: "£0.99"
    )

    let id = try inbox.store(transaction)
    let loaded = try inbox.load(id: id)

    #expect(loaded == transaction)
    #expect(try inbox.listIDs() == ["tx-123"])
  }
}
