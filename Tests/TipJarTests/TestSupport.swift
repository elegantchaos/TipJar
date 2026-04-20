import Commands
import Foundation
@testable import TipJar
@testable import TipJarUI
@testable import TipJarUbiquitousStore

@MainActor
final class InMemoryPurchaseHistory: TipJarPurchaseHistory {
  private(set) var purchases: [TipJarPurchaseRecord]
  private(set) var savedTransactions: [String] = []

  init(purchases: [TipJarPurchaseRecord] = []) {
    self.purchases = purchases
  }

  func containsTransaction(id: String) throws -> Bool {
    purchases.contains(where: { $0.transactionID == id })
  }

  func save(_ purchase: TipJarPurchaseRecord) throws {
    guard purchases.contains(where: { $0.transactionID == purchase.transactionID }) == false else {
      return
    }
    purchases.append(purchase)
    savedTransactions.append(purchase.transactionID)
  }

  func loadRecent(limit: Int) throws -> [TipJarPurchaseRecord] {
    Array(purchases.sorted { $0.purchaseDate > $1.purchaseDate }.prefix(limit))
  }
}

final class FakeUbiquitousStore: UbiquitousKeyValueStoring {
  private var storage: [String: Data] = [:]

  func data(forKey key: String) -> Data? {
    storage[key]
  }

  func set(_ value: Data?, forKey key: String) {
    storage[key] = value
  }

  func synchronize() -> Bool {
    true
  }
}

@MainActor
final class TipJarTestCommander: CommandCentre, TipJarServiceProvider, TipJarPresenter {
  let store = MockTipJarStore()
  let tipJarService: TipJarService
  private(set) var didShowTipJar = false

  init() {
    tipJarService = TipJarService(
      configuration: TipJarConfiguration(productPrefix: "com.elegantchaos.actionstatus"),
      purchaseHistory: InMemoryPurchaseHistory(),
      store: store
    )
  }

  func showTipJar() {
    didShowTipJar = true
  }
}
