import Commands
import Foundation
import Testing
import TipJar
import TipJarUI

@MainActor
@Suite("TipJar Command Tests")
struct TipJarCommandTests {
  @Test("purchase command invokes the selected size")
  func purchaseCommand() async throws {
    let commander = TipJarTestCommander()

    try await PurchaseTipCommand<TipJarTestCommander>(size: .medium).perform(centre: commander)

    #expect(commander.tipJarService.state == .loaded)
    #expect(commander.store.purchasedSizes == [.medium])
  }

  @Test("show command asks the presenter to show the tip jar")
  func showCommand() async throws {
    let commander = TipJarTestCommander()

    try await ShowTipJarCommand<TipJarTestCommander>().perform(centre: commander)

    #expect(commander.didShowTipJar)
  }
}
