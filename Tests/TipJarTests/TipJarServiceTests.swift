import Foundation
import Testing
@testable import TipJar

@MainActor
@Suite("TipJarService Tests")
struct TipJarServiceTests {
  let configuration = TipJarConfiguration(productPrefix: "com.elegantchaos.actionstatus")

  @Test("loadProducts populates products and recent purchases")
  func loadProductsSuccess() async {
    let store = MockTipJarStore()
    store.productsToReturn = [
      TipJarProduct(
        size: .small,
        productID: configuration.productID(for: .small),
        title: "Small Tip",
        displayPrice: "£0.99"
      )
    ]
    let history = InMemoryPurchaseHistory(
      purchases: [
        TipJarPurchaseRecord(
          productID: configuration.productID(for: .medium),
          transactionID: "existing",
          purchaseDate: Date(timeIntervalSince1970: 100),
          displayPrice: "£2.99"
        )
      ]
    )
    let service = TipJarService(configuration: configuration, purchaseHistory: history, store: store)

    await service.loadProducts()

    #expect(service.state == .loaded)
    #expect(service.products.count == 1)
    #expect(service.recentPurchases.count == 1)
  }

  @Test("purchase records selected size")
  func purchaseInvokesStore() async throws {
    let store = MockTipJarStore()
    let history = InMemoryPurchaseHistory()
    let service = TipJarService(configuration: configuration, purchaseHistory: history, store: store)

    try await service.purchase(.medium)

    #expect(store.purchasedSizes == [.medium])
    #expect(service.state == .loaded)
  }

  @Test("recovered stored transactions persist exactly once")
  func recoveredTransactionsPersistOnce() async {
    let store = MockTipJarStore()
    store.productsToReturn = [
      TipJarProduct(
        size: .small,
        productID: configuration.productID(for: .small),
        title: "Small Tip",
        displayPrice: "£0.99"
      )
    ]
    let history = InMemoryPurchaseHistory()
    let service = TipJarService(configuration: configuration, purchaseHistory: history, store: store)
    await service.loadProducts()
    try? await Task.sleep(for: .milliseconds(50))

    let transaction = VerifiedTipJarTransaction(
      size: .small,
      productID: configuration.productID(for: .small),
      transactionID: "tx-1",
      purchaseDate: Date(timeIntervalSince1970: 1000),
      displayPrice: "£0.99"
    )

    store.simulateStoredTransaction(transaction)
    store.simulateStoredTransaction(transaction)

    for _ in 0..<10 where service.recentPurchases.isEmpty {
      try? await Task.sleep(for: .milliseconds(20))
    }

    #expect(service.recentPurchases.count == 1)
    #expect(history.savedTransactions == ["tx-1"])
    #expect(store.storedTransactions.isEmpty)
  }

  @Test("title derives from product when present")
  func titleUsesLoadedProduct() async {
    let store = MockTipJarStore()
    store.productsToReturn = [
      TipJarProduct(
        size: .large,
        productID: configuration.productID(for: .large),
        title: "Large Tip",
        displayPrice: "£9.99"
      )
    ]
    let service = TipJarService(configuration: configuration, purchaseHistory: InMemoryPurchaseHistory(), store: store)
    await service.loadProducts()

    let purchase = TipJarPurchaseRecord(
      productID: configuration.productID(for: .large),
      transactionID: "tx-2",
      purchaseDate: Date(),
      displayPrice: ""
    )

    #expect(service.title(for: purchase) == "Large Tip")
    #expect(service.price(for: purchase) == "£9.99")
  }
}
