import FirebaseCore
import FirebaseInstallations
import Foundation

public final class FirebaseInstallationsProvider {
    public init() {}

    public func getInstallationID() async -> String? {
        guard FirebaseApp.app() != nil else { return nil }
        try? await Installations.installations().installationID()
    }
}
