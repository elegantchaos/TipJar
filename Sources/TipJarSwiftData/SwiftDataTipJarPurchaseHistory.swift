// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import SwiftData
import TipJar

@Model
public final class PersistedTipJarPurchase {
  public var productID = ""
  public var transactionID = ""
  public var purchaseDate = Date.distantPast
  public var displayPrice = ""

  public init(
    productID: String,
    transactionID: String,
    purchaseDate: Date,
    displayPrice: String
  ) {
    self.productID = productID
    self.transactionID = transactionID
    self.purchaseDate = purchaseDate
    self.displayPrice = displayPrice
  }
}

/// SwiftData-backed purchase history adapter.
@MainActor
public struct SwiftDataTipJarPurchaseHistory: TipJarPurchaseHistory {
  private let modelContext: ModelContext

  public init(modelContext: ModelContext) {
    self.modelContext = modelContext
  }

  public func containsTransaction(id: String) throws -> Bool {
    var descriptor = FetchDescriptor<PersistedTipJarPurchase>()
    descriptor.predicate = #Predicate { $0.transactionID == id }
    descriptor.fetchLimit = 1
    return try modelContext.fetch(descriptor).isEmpty == false
  }

  public func save(_ purchase: TipJarPurchaseRecord) throws {
    guard try containsTransaction(id: purchase.transactionID) == false else {
      return
    }

    modelContext.insert(
      PersistedTipJarPurchase(
        productID: purchase.productID,
        transactionID: purchase.transactionID,
        purchaseDate: purchase.purchaseDate,
        displayPrice: purchase.displayPrice
      )
    )
    try modelContext.save()
  }

  public func loadRecent(limit: Int) throws -> [TipJarPurchaseRecord] {
    var descriptor = FetchDescriptor<PersistedTipJarPurchase>()
    descriptor.fetchLimit = limit
    return try modelContext.fetch(descriptor)
      .sorted { $0.purchaseDate > $1.purchaseDate }
      .map {
        TipJarPurchaseRecord(
          productID: $0.productID,
          transactionID: $0.transactionID,
          purchaseDate: $0.purchaseDate,
          displayPrice: $0.displayPrice
        )
      }
  }
}
