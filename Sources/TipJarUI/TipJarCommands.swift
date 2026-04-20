// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/04/2026.
//  Copyright © 2026 Elegant Chaos Limited. All rights reserved.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Commands
import CommandsUI
import Foundation
import Icons
import TipJar

/// Provider for a shared `TipJarService`.
@MainActor
public protocol TipJarServiceProvider: CommandCentre {
  var tipJarService: TipJarService { get }
}

/// Host-controlled presentation surface for the Tip Jar sheet.
@MainActor
public protocol TipJarPresenter: CommandCentre {
  func showTipJar()
}

/// Command that asks the host app to show the Tip Jar sheet.
public struct ShowTipJarCommand<C: TipJarPresenter>: CommandWithUI {
  public let id = "tip-jar.show"
  public let icon = Icon("heart.circle")

  public init() {
  }

  public func perform(centre: C) async throws {
    centre.showTipJar()
  }
}

/// Command that reloads products from StoreKit.
public struct ReloadTipJarProductsCommand<C: TipJarServiceProvider>: CommandWithUI {
  public let id = "tip-jar.reload"
  public let icon = Icon("arrow.clockwise")

  public init() {
  }

  public func perform(centre: C) async throws {
    await centre.tipJarService.loadProducts()
  }
}

/// Command that purchases a configured tip size.
public struct PurchaseTipCommand<C: TipJarServiceProvider>: CommandWithUI {
  public let size: TipJarSize
  public let icon = Icon("heart.fill")

  public init(size: TipJarSize) {
    self.size = size
  }

  public var id: String {
    "tip-jar.purchase.\(size.rawValue)"
  }

  public func perform(centre: C) async throws {
    try await centre.tipJarService.purchase(size)
  }
}
