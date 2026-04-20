// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import TipJar

/// Local JSON-backed purchase history.
@MainActor
public struct LocalTipJarPurchaseHistory: TipJarPurchaseHistory {
  private let fileURL: URL

  public init(applicationID: String) throws {
    let fileManager = FileManager.default
    guard let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
      throw HistoryError.missingApplicationSupportDirectory
    }

    let directoryURL = appSupport
      .appending(path: applicationID, directoryHint: .isDirectory)
      .appending(path: "TipJar", directoryHint: .isDirectory)

    try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
    self.fileURL = directoryURL.appending(path: "PurchaseHistory.json")
  }

  init(fileURL: URL) {
    self.fileURL = fileURL
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
    guard FileManager.default.fileExists(atPath: fileURL.path()) else {
      return []
    }

    let data = try Data(contentsOf: fileURL)
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try decoder.decode([TipJarPurchaseRecord].self, from: data)
  }

  private func write(_ purchases: [TipJarPurchaseRecord]) throws {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try encoder.encode(purchases)
    try data.write(to: fileURL, options: .atomic)
  }

  enum HistoryError: Error {
    case missingApplicationSupportDirectory
  }
}
