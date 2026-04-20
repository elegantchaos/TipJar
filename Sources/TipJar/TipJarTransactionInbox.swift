// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// File-backed inbox that durably stores verified transactions before finishing them.
struct TipJarTransactionInbox: Sendable {
  /// Directory containing one JSON file per transaction, or `nil` when storage is disabled.
  private let directoryURL: URL?

  /// Disabled inbox used when local filesystem access is unavailable.
  static let disabled = TipJarTransactionInbox(directoryURL: nil)

  /// Creates a filesystem-backed inbox inside Application Support for the supplied app identifier.
  init(applicationID: String) throws {
    let fileManager = FileManager.default
    guard let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
      throw StorageError.missingApplicationSupportDirectory
    }

    let directoryURL = appSupport
      .appending(path: applicationID, directoryHint: .isDirectory)
      .appending(path: "TipJarTransactions", directoryHint: .isDirectory)

    try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
    self.directoryURL = directoryURL
  }

  /// Creates an inbox for tests or a disabled inbox when passed `nil`.
  init(directoryURL: URL?) {
    self.directoryURL = directoryURL
  }

  /// Stores a verified transaction payload and returns its inbox identifier.
  func store(_ transaction: VerifiedTipJarTransaction) throws -> String {
    guard let directoryURL else {
      throw TipJarStoreError.storageUnavailable
    }

    let url = Self.makeURL(for: transaction.transactionID, in: directoryURL)
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    let data = try encoder.encode(transaction)
    try data.write(to: url, options: .atomic)
    return transaction.transactionID
  }

  /// Returns all currently persisted inbox identifiers.
  func listIDs() throws -> [String] {
    guard let directoryURL else { return [] }

    return try FileManager.default.contentsOfDirectory(
      at: directoryURL,
      includingPropertiesForKeys: nil,
      options: [.skipsHiddenFiles]
    )
    .filter { $0.pathExtension == "json" }
    .map { $0.deletingPathExtension().lastPathComponent }
    .sorted()
  }

  /// Loads a previously persisted inbox entry.
  func load(id: String) throws -> VerifiedTipJarTransaction {
    guard let directoryURL else {
      throw TipJarStoreError.storageUnavailable
    }

    let data = try Data(contentsOf: Self.makeURL(for: id, in: directoryURL))
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try decoder.decode(VerifiedTipJarTransaction.self, from: data)
  }

  /// Deletes an inbox entry after durable persistence succeeds elsewhere.
  func delete(id: String) throws {
    guard let directoryURL else {
      throw TipJarStoreError.storageUnavailable
    }

    try FileManager.default.removeItem(at: Self.makeURL(for: id, in: directoryURL))
  }

  /// Returns the on-disk location for an inbox entry identifier.
  static func makeURL(for id: String, in directoryURL: URL) -> URL {
    directoryURL.appending(path: "\(id).json")
  }

  /// Errors thrown when inbox storage cannot be initialized.
  enum StorageError: Error {
    case missingApplicationSupportDirectory
  }
}
