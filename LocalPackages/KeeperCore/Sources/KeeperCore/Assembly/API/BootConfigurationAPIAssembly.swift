import Foundation

final class BootConfigurationAPIAssembly {
    private let appInfoProvider: AppInfoProvider
    private let requestContextProvider: @Sendable () -> BootConfigurationRequestContext

    init(
        appInfoProvider: AppInfoProvider,
        requestContextProvider: @escaping @Sendable () -> BootConfigurationRequestContext
    ) {
        self.appInfoProvider = appInfoProvider
        self.requestContextProvider = requestContextProvider
    }

    var api: BootConfigurationAPI {
        BootConfigurationAPIImplementation(
            urlSession: .shared,
            bootHost: apiV1BootURL,
            blockHost: apiV1BlockURL,
            appInfoProvider: appInfoProvider,
            requestContextProvider: requestContextProvider
        )
    }

    var apiV1BootURL: URL {
        .noServer
    }

    var apiV1BlockURL: URL {
        .noServer
    }
}
