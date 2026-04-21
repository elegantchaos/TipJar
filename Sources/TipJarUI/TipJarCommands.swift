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
  /// Shared Tip Jar service used to load products and perform purchases.
  var tipJarService: TipJarService { get }
}

/// Host-controlled presentation surface for the Tip Jar sheet.
@MainActor
public protocol TipJarPresenter: CommandCentre {
  /// Presents the host app's Tip Jar UI.
  func showTipJar()
}

/// Command that asks the host app to show the Tip Jar sheet.
public struct ShowTipJarCommand<C: TipJarPresenter>: CommandWithUI {
  /// Stable identifier used for localization and UI wiring.
  public let id = "tip-jar.show"

  public init() {
  }

  /// Fixed icon used when surfacing the command in UI.
  public func icon(centre: C) -> Icon {
    Icon("heart.circle")
  }

  /// Asks the host application to present the Tip Jar UI.
  public func perform(centre: C) async throws {
    centre.showTipJar()
  }
}

/// Command that reloads products from StoreKit.
public struct ReloadTipJarProductsCommand<C: TipJarServiceProvider>: CommandWithUI {
  /// Stable identifier used for localization and UI wiring.
  public let id = "tip-jar.reload"

  public init() {
  }

  /// Fixed icon used when surfacing the command in UI.
  public func icon(centre: C) -> Icon {
    Icon("arrow.clockwise")
  }

  /// Reloads products from StoreKit through the shared service.
  public func perform(centre: C) async throws {
    await centre.tipJarService.loadProducts()
  }
}

/// Command that purchases a configured tip size.
public struct PurchaseTipCommand<C: TipJarServiceProvider>: CommandWithUI {
  /// Tip size to purchase when the command executes.
  public let size: TipJarSize

  public init(size: TipJarSize) {
    self.size = size
  }

  /// Stable identifier derived from the selected size.
  public var id: String {
    "tip-jar.purchase.\(size.rawValue)"
  }

  /// Fixed icon used when surfacing the command in UI.
  public func icon(centre: C) -> Icon {
    Icon("heart.fill")
  }

  /// Starts a purchase for the configured tip size.
  public func perform(centre: C) async throws {
    try await centre.tipJarService.purchase(size)
  }
}
