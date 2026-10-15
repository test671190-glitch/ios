import Foundation
import TonAPI

public protocol BuySellMethodsService {
    func loadFiatMethods(countryCode: String?, walletId: String?) async throws -> FiatMethods
}

final class BuySellMethodsServiceImplementation: BuySellMethodsService {
    private let api: TonkeeprDemoModeAPI
    private let buySellMethodsRepository: BuySellMethodsRepository

    init(
        api: TonkeeprDemoModeAPI,
        buySellMethodsRepository: BuySellMethodsRepository
    ) {
        self.api = api
        self.buySellMethodsRepository = buySellMethodsRepository
    }

    func loadFiatMethods(countryCode: String?, walletId: String?) async throws -> FiatMethods {
        try await api.loadFiatMethods(countryCode: countryCode, walletId: walletId)
    }
}
