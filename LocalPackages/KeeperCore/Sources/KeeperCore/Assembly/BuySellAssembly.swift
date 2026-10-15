import Foundation

public final class BuySellAssembly {
    private let tonkeeprDemoModeApiAssembly: TonkeeprDemoModeAPIAssembly
    private let coreAssembly: CoreAssembly

    init(
        tonkeeprDemoModeApiAssembly: TonkeeprDemoModeAPIAssembly,
        coreAssembly: CoreAssembly
    ) {
        self.tonkeeprDemoModeApiAssembly = tonkeeprDemoModeApiAssembly
        self.coreAssembly = coreAssembly
    }

    public func buySellMethodsService() -> BuySellMethodsService {
        BuySellMethodsServiceImplementation(
            api: tonkeeprDemoModeApiAssembly.api,
            buySellMethodsRepository: buySellMethodsRepository()
        )
    }

    func buySellMethodsRepository() -> BuySellMethodsRepository {
        BuySellMethodsRepositoryImplementation(fileSystemVault: coreAssembly.fileSystemVault())
    }
}
