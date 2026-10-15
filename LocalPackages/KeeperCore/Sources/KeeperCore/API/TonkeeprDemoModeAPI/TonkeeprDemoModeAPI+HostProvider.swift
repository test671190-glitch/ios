import Foundation

struct TonkeeprDemoModeAPIHostProvider: APIHostProvider {
    private let defaultHost: URL
    private let configHost: () -> URL?

    init(
        defaultHost: URL,
        configHost: @escaping () -> URL?
    ) {
        self.defaultHost = defaultHost
        self.configHost = configHost
    }

    var basePath: String {
        get async {
            (configHost() ?? defaultHost).absoluteString
        }
    }
}
