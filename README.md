# TipJar

`TipJar` is a reusable Swift package for simple in-app support tips built on StoreKit 2.

It provides:

- fixed tip sizes: `small`, `medium`, `large`
- product ID derivation from an app-specific prefix
- write-ahead transaction recovery before `Transaction.finish()`
- pluggable purchase-history persistence
- command-backed SwiftUI integration for apps using `elegantchaos/Commands`

Available targets:

- `TipJar`: core types, StoreKit integration, and the shared service
- `TipJarUI`: command-backed SwiftUI view and commands
- `TipJarLocalStore`: local JSON-backed purchase history
- `TipJarUbiquitousStore`: optional `NSUbiquitousKeyValueStore` history
- `TipJarSwiftData`: optional SwiftData-backed history
