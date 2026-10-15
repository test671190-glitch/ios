import Foundation

final class CurrenciesAPIAssembly {
    private let appInfoProvider: AppInfoProvider

    init(appInfoProvider: AppInfoProvider) {
        self.appInfoProvider = appInfoProvider
    }

    var api: CurrenciesAPI {
        CurrenciesAPIImplementation(
            urlSession: .shared,
            bootHost: apiV1BootURL,
            blockHost: apiV1BlockURL,
            appInfoProvider: appInfoProvider
        )
    }

    var apiV1BootURL: URL {
        .noServer
    }

    var apiV1BlockURL: URL {
        .noServer
    }
}
