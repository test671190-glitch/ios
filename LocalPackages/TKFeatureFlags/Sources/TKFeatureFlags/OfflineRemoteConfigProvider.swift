/// Demo mode: remote config is never fetched, so every flag falls back to its local default.
public struct OfflineRemoteConfigProvider: RemoteConfigProvider {
    public init() {}

    public func load() async {}

    public subscript(_: String) -> Bool? {
        nil
    }
}
