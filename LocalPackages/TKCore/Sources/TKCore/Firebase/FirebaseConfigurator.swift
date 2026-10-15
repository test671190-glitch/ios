import Foundation

public final class FirebaseConfigurator: NSObject {
    public static let configurator = FirebaseConfigurator()

    override private init() {}

    public func configure() {
        // Demo mode: Firebase is never configured, so it opens no connections to Google servers.
        // Every Firebase call site checks `FirebaseApp.app()` and does nothing without it.
    }
}
