import ChainKit
import Foundation
import ReownWalletKit
import TKLogging

public final class WalletConnectAssembly {
    public private(set) lazy var walletConnectDeeplinkValidator: WalletConnectDeeplinkValidator = WalletConnectDeeplinkValidatorImplementation()

    public private(set) lazy var walletConnectSigningService: WalletConnectSigningService = WalletConnectSigningService(
        mnemonicAccess: mnemonicAccess,
        client: chainKitClient,
        pendingTransactionsService: pendingTransactionsService
    )

    @WalletConnectActor
    public private(set) lazy var walletConnectService: WalletConnectService = WalletConnectServiceImplementation(
        eventStream: walletConnectEventStream,
        network: walletConnectWalletKitClient,
        sessionRepository: walletConnectSessionRepository,
        pairingSourceStore: walletConnectPairingSourceStore,
        autoRejectService: WalletConnectAutoRejectService(
            network: walletConnectWalletKitClient
        )
    )

    @WalletConnectActor
    public private(set) lazy var walletConnectWalletsSynchronizer = WalletConnectWalletsSynchronizer(
        walletConnectService: walletConnectService,
        walletsStore: walletsStore
    )

    @WalletConnectActor
    private lazy var walletConnectWalletKitClient = WalletConnectWalletKitClient(
        configurationProvider: walletConnectConfiguration,
        networkConnectionStatusProvider: walletConnectNetworkConnectionStatusProvider
    )

    @WalletConnectActor
    private lazy var walletConnectNetworkConnectionStatusProvider = WalletConnectNetworkConnectionStatusProvider()

    @WalletConnectActor
    private lazy var walletConnectEventStream = WalletConnectEventStream()

    @WalletConnectActor
    private lazy var walletConnectSessionRepository = WalletConnectSessionRepository(
        store: walletConnectSessionStore
    )

    @WalletConnectActor
    private lazy var walletConnectSessionStore: WalletConnectSessionStore = WalletConnectSessionStore(
        vault: coreAssembly.sharedFileSystemVault()
    )

    @WalletConnectActor
    private lazy var walletConnectPairingSourceStore: WalletConnectPairingSourceStore = WalletConnectPairingSourceStore(
        vault: coreAssembly.sharedFileSystemVault()
    )

    @WalletConnectActor
    private func walletConnectConfiguration() throws(WalletConnectConfigurationError) -> WalletConnectConfiguration {
        // Demo mode: the WalletConnect relay server is cut out, so the SDK is never configured.
        throw .sdk(message: "WalletConnect is disabled in demo mode")
    }

    private let mnemonicAccess: MnemonicAccess
    private let coreAssembly: CoreAssembly
    private let walletsStore: WalletsStore
    private let chainKitClient: CryptoKitClient
    private let pendingTransactionsService: PendingTransactionsService

    init(
        mnemonicAccess: MnemonicAccess,
        coreAssembly: CoreAssembly,
        walletsStore: WalletsStore,
        chainKitClient: CryptoKitClient,
        pendingTransactionsService: PendingTransactionsService
    ) {
        self.mnemonicAccess = mnemonicAccess
        self.coreAssembly = coreAssembly
        self.walletsStore = walletsStore
        self.chainKitClient = chainKitClient
        self.pendingTransactionsService = pendingTransactionsService
    }
}
