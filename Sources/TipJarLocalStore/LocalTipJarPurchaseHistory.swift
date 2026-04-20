// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import TipJar

/// Local JSON-backed purchase history.
@MainActor
public struct LocalTipJarPurchaseHistory: TipJarPurchaseHistory {
  /// Backing file that stores the JSON purchase history payload.
  private let fileURL: URL

  /// Creates a local purchase history store inside Application Support for the supplied app identifier.
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

  /// Creates a file-backed history for tests.
  init(fileURL: URL) {
    self.fileURL = fileURL
  }

  /// Returns whether the supplied transaction identifier is already present in the file.
  public func containsTransaction(id: String) throws -> Bool {
    try loadAll().contains(where: { $0.transactionID == id })
  }

  /// Appends a purchase record unless it has already been persisted.
  public func save(_ purchase: TipJarPurchaseRecord) throws {
    var purchases = try loadAll()
    guard purchases.contains(where: { $0.transactionID == purchase.transactionID }) == false else {
      return
    }
    purchases.append(purchase)
    try write(purchases)
  }

  /// Loads recent purchases from disk, returning at most the requested number of records.
  public func loadRecent(limit: Int) throws -> [TipJarPurchaseRecord] {
    Array(
      try loadAll()
        .sorted { $0.purchaseDate > $1.purchaseDate }
        .prefix(limit)
    )
  }

  /// Loads the complete history payload from disk.
  private func loadAll() throws -> [TipJarPurchaseRecord] {
    guard FileManager.default.fileExists(atPath: fileURL.path()) else {
      return []
    }

    let data = try Data(contentsOf: fileURL)
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try decoder.decode([TipJarPurchaseRecord].self, from: data)
  }

  /// Writes the full history payload atomically to disk.
  private func write(_ purchases: [TipJarPurchaseRecord]) throws {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try encoder.encode(purchases)
    try data.write(to: fileURL, options: .atomic)
  }

  /// Errors thrown when local history storage cannot be initialized.
  enum HistoryError: Error {
    case missingApplicationSupportDirectory
  }
}
