// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import TipJar

protocol UbiquitousKeyValueStoring {
  func data(forKey key: String) -> Data?
  func set(_ value: Data?, forKey key: String)
  @discardableResult func synchronize() -> Bool
}

extension NSUbiquitousKeyValueStore: UbiquitousKeyValueStoring {
}

/// `NSUbiquitousKeyValueStore`-backed purchase history.
@MainActor
public struct UbiquitousTipJarPurchaseHistory: TipJarPurchaseHistory {
  private let key: String
  private let store: any UbiquitousKeyValueStoring

  public init(
    key: String = "TipJarPurchases",
    store: NSUbiquitousKeyValueStore = .default
  ) {
    self.key = key
    self.store = store
  }

  init(key: String = "TipJarPurchases", store: any UbiquitousKeyValueStoring) {
    self.key = key
    self.store = store
  }

  public func containsTransaction(id: String) throws -> Bool {
    try loadAll().contains(where: { $0.transactionID == id })
  }

  public func save(_ purchase: TipJarPurchaseRecord) throws {
    var purchases = try loadAll()
    guard purchases.contains(where: { $0.transactionID == purchase.transactionID }) == false else {
      return
    }
    purchases.append(purchase)
    try write(purchases)
  }

  public func loadRecent(limit: Int) throws -> [TipJarPurchaseRecord] {
    Array(
      try loadAll()
        .sorted { $0.purchaseDate > $1.purchaseDate }
        .prefix(limit)
    )
  }

  private func loadAll() throws -> [TipJarPurchaseRecord] {
    guard let data = store.data(forKey: key) else {
      return []
    }

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try decoder.decode([TipJarPurchaseRecord].self, from: data)
  }

  private func write(_ purchases: [TipJarPurchaseRecord]) throws {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    let data = try encoder.encode(purchases)
    store.set(data, forKey: key)
    store.synchronize()
  }
}
