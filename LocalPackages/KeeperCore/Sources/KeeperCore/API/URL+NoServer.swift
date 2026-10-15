import Foundation

public extension URL {
    /// Demo mode: every server address is cut out of the app. Places that need a non-optional
    /// URL point here instead, so requests fail locally and never reach the network.
    static let noServer = URL(string: "about:blank")!
}
