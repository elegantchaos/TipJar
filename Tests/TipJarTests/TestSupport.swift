import Commands
import Foundation
@testable import TipJar
@testable import TipJarUI
@testable import TipJarUbiquitousStore

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
      purchaseHistory: InMemoryTipJarPurchaseHistory(),
      store: store
    )
  }

  func showTipJar() {
    didShowTipJar = true
  }
}
