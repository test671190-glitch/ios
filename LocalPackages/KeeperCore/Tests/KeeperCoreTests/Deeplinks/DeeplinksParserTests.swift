import BigInt
@testable import KeeperCore
import KeeperCoreComponents
import TonSwift
import XCTest

final class DeeplinksParserTests: XCTestCase {
    let parser = DeeplinkParser(
        walletConnectDeeplinkValidator: WalletConnectDeeplinkValidatorImplementation()
    )

    func testTransferTonkeeprDemoModeDeeplinkParsing() throws {
        let address = "EQD2NmD_lH5f5u1Kj3KfGyTvhZSX0Eg6qp2a5IQUKXxOG21n"
        let text = "just comment"
        let amount = "10000"

        let string = "tonkeeprdemomode://transfer/\(address)?text=\(text)&amount=\(amount)"
        let transferData = Deeplink.TransferData(
            recipient: address,
            amount: BigUInt(amount),
            comment: text,
            jettonAddress: nil,
            assetId: nil,
            expirationTimestamp: nil,
            successReturn: nil
        )
        let result = Deeplink.transfer(.sendTransfer(transferData))
        let parsedDeeplink = try parser.parse(string: string)

        XCTAssertEqual(parsedDeeplink, result)
    }

    func testTransferTonDeeplinkParsing() throws {
        let address = "EQD2NmD_lH5f5u1Kj3KfGyTvhZSX0Eg6qp2a5IQUKXxOG21n"
        let text = "just comment"
        let amount = "10000"

        let string = "ton://transfer/\(address)?text=\(text)&amount=\(amount)"
        let transferData = Deeplink.TransferData(
            recipient: address,
            amount: BigUInt(amount),
            comment: text,
            jettonAddress: nil,
            assetId: nil,
            expirationTimestamp: nil,
            successReturn: nil
        )
        let result = Deeplink.transfer(.sendTransfer(transferData))
        let parsedDeeplink = try parser.parse(string: string)

        XCTAssertEqual(parsedDeeplink, result)
    }

    func testStakingTonDeeplinkParsing() throws {
        let string = "ton://staking"
        let result = Deeplink.staking

        let parsedDeeplink = try parser.parse(string: string)

        XCTAssertEqual(parsedDeeplink, result)
    }

    func testStakingTonkeeprDemoModeDeeplinkParsing() throws {
        let string = "tonkeeprdemomode://staking"
        let result = Deeplink.staking

        let parsedDeeplink = try parser.parse(string: string)

        XCTAssertEqual(parsedDeeplink, result)
    }

    func testSwapTonDeeplinkParsing() throws {
        let string = "ton://swap?ft=TON&tt=FNZ"
        let swapData = Deeplink.SwapData(
            fromToken: "TON",
            toToken: "FNZ"
        )
        let result = Deeplink.swap(swapData)

        let parsedDeeplink = try parser.parse(string: string)

        XCTAssertEqual(parsedDeeplink, result)
    }

    func testSwapTonkeeprDemoModeDeeplinkParsing() throws {
        let string = "tonkeeprdemomode://swap?ft=TON&tt=FNZ"
        let swapData = Deeplink.SwapData(
            fromToken: "TON",
            toToken: "FNZ"
        )
        let result = Deeplink.swap(swapData)

        let parsedDeeplink = try parser.parse(string: string)

        XCTAssertEqual(parsedDeeplink, result)
    }

    func testActionTonDeeplinkParsing() throws {
        let string = "ton://action/f0389f350dd7b6bba35ce0dd12d4e2cf557c2613bca2426d2e0c3055ac105994"
        let result = Deeplink.action(eventId: "f0389f350dd7b6bba35ce0dd12d4e2cf557c2613bca2426d2e0c3055ac105994")

        let parsedDeeplink = try parser.parse(string: string)

        XCTAssertEqual(parsedDeeplink, result)
    }

    func testActionTonkeeprDemoModeDeeplinkParsing() throws {
        let string = "tonkeeprdemomode://action/f0389f350dd7b6bba35ce0dd12d4e2cf557c2613bca2426d2e0c3055ac105994"
        let result = Deeplink.action(eventId: "f0389f350dd7b6bba35ce0dd12d4e2cf557c2613bca2426d2e0c3055ac105994")

        let parsedDeeplink = try parser.parse(string: string)

        XCTAssertEqual(parsedDeeplink, result)
    }

    func testPoolTonDeeplinkParsing() throws {
        let string = "ton://pool/0:a45b17f28409229b78360e3290420f13e4fe20f90d7e2bf8c4ac6703259e22fa"
        let result = try Deeplink.pool(Address.parse("0:a45b17f28409229b78360e3290420f13e4fe20f90d7e2bf8c4ac6703259e22fa"))

        let parsedDeeplink = try parser.parse(string: string)

        XCTAssertEqual(parsedDeeplink, result)
    }

    func testPoolTonkeeprDemoModeDeeplinkParsing() throws {
        let string = "tonkeeprdemomode://pool/0:a45b17f28409229b78360e3290420f13e4fe20f90d7e2bf8c4ac6703259e22fa"
        let result = try Deeplink.pool(Address.parse("0:a45b17f28409229b78360e3290420f13e4fe20f90d7e2bf8c4ac6703259e22fa"))

        let parsedDeeplink = try parser.parse(string: string)

        XCTAssertEqual(parsedDeeplink, result)
    }

    func testPoolTonkeeprDemoModeUnversalLinkParsing() throws {
        let string = "ton://pool/0:a45b17f28409229b78360e3290420f13e4fe20f90d7e2bf8c4ac6703259e22fa"
        let result = try Deeplink.pool(Address.parse("0:a45b17f28409229b78360e3290420f13e4fe20f90d7e2bf8c4ac6703259e22fa"))

        let parsedDeeplink = try parser.parse(string: string)

        XCTAssertEqual(parsedDeeplink, result)
    }

    func testPublishTonDeeplinkParsing() throws {
        let string = "ton://publish?sign=9dfab96f693363f48a641c628ae74168d37f7da1745bfd3cbf1b6013cce1477c03ae59e87c8ebe0146c1d755b797020ac29ff6a1797e7ae7d4b61df89c34540f"
        let data = try XCTUnwrap(Data(strictHex: "9dfab96f693363f48a641c628ae74168d37f7da1745bfd3cbf1b6013cce1477c03ae59e87c8ebe0146c1d755b797020ac29ff6a1797e7ae7d4b61df89c34540f"))
        let result = Deeplink.publish(sign: data)

        let parsedDeeplink = try parser.parse(string: string)

        XCTAssertEqual(parsedDeeplink, result)
    }

    func testPublishTonkeeprDemoModeDeeplinkParsing() throws {
        let string = "tonkeeprdemomode://publish?sign=9dfab96f693363f48a641c628ae74168d37f7da1745bfd3cbf1b6013cce1477c03ae59e87c8ebe0146c1d755b797020ac29ff6a1797e7ae7d4b61df89c34540f"
        let data = try XCTUnwrap(Data(strictHex: "9dfab96f693363f48a641c628ae74168d37f7da1745bfd3cbf1b6013cce1477c03ae59e87c8ebe0146c1d755b797020ac29ff6a1797e7ae7d4b61df89c34540f"))
        let result = Deeplink.publish(sign: data)

        let parsedDeeplink = try parser.parse(string: string)

        XCTAssertEqual(parsedDeeplink, result)
    }

    func testSignerLinkTonDeeplinkParsing() throws {
        let pk = "db642e022c80911fe61f19eb4f22d7fb95c1ea0b589c0f74ecf0cbf6db746c13"
        let name = "MyKey"
        let publicKey = try TonSwift.PublicKey(data: XCTUnwrap(Data(strictHex: pk)))
        let string = "ton://signer/link?pk=\(pk)&name=\(name)"
        let result = Deeplink.externalSign(
            ExternalSignDeeplink.link(
                publicKey: publicKey,
                name: name
            )
        )

        let parsedDeeplink = try parser.parse(string: string)

        XCTAssertEqual(parsedDeeplink, result)
    }

    func testSignerLinkTonkeeprDemoModeDeeplinkParsing() throws {
        let pk = "db642e022c80911fe61f19eb4f22d7fb95c1ea0b589c0f74ecf0cbf6db746c13"
        let name = "MyKey"
        let publicKey = try TonSwift.PublicKey(data: XCTUnwrap(Data(strictHex: pk)))
        let string = "tonkeeprdemomode://signer/link?pk=\(pk)&name=\(name)"
        let result = Deeplink.externalSign(
            ExternalSignDeeplink.link(
                publicKey: publicKey,
                name: name
            )
        )

        let parsedDeeplink = try parser.parse(string: string)

        XCTAssertEqual(parsedDeeplink, result)
    }

    func testReceiveTonkeeprDemoModeDeeplinkParsing() throws {
        let string = "tonkeeprdemomode://receive"
        let result = Deeplink.receive

        let parsedDeeplink = try parser.parse(string: string)

        XCTAssertEqual(parsedDeeplink, result)
    }

    func testReceiveTonDeeplinkParsing() throws {
        let string = "ton://receive"
        let result = Deeplink.receive

        let parsedDeeplink = try parser.parse(string: string)

        XCTAssertEqual(parsedDeeplink, result)
    }

    func testBackupTonkeeprDemoModeDeeplinkParsing() throws {
        let string = "tonkeeprdemomode://backup"
        let result = Deeplink.backup

        let parsedDeeplink = try parser.parse(string: string)

        XCTAssertEqual(parsedDeeplink, result)
    }

    func testBackupTonDeeplinkParsing() throws {
        let string = "ton://backup"
        let result = Deeplink.backup

        let parsedDeeplink = try parser.parse(string: string)

        XCTAssertEqual(parsedDeeplink, result)
    }

    func testAddWalletTonkeeprDemoModeDeeplinkParsing() throws {
        XCTAssertEqual(try parser.parse(string: "tonkeeprdemomode://add-wallet"), .addWallet)
    }

    func testDepositTonLinkParsing() throws {
        let params = RampDeeplinkParameters(
            fromToken: "TON",
            toToken: nil,
            toNetwork: nil,
            fromNetwork: nil,
            cashMethod: nil
        )
        let string = "ton://deposit?ft=TON"
        let parsedDeeplink = try parser.parse(string: string)
        XCTAssertEqual(parsedDeeplink, Deeplink.deposit(params))
    }

    func testWithdrawTonLinkParsing() throws {
        let params = RampDeeplinkParameters(
            fromToken: "USDT",
            toToken: "USDT",
            toNetwork: "ton",
            fromNetwork: "trc20",
            cashMethod: nil
        )
        let string = "ton://withdraw?ft=USDT&fn=trc20&tt=USDT&tn=ton"
        let parsedDeeplink = try parser.parse(string: string)
        XCTAssertEqual(parsedDeeplink, Deeplink.withdraw(params))
    }

    func testTradingTonLinkParsing() throws {
        let string = "ton://trading"
        let parsedDeeplink = try parser.parse(string: string)
        XCTAssertEqual(parsedDeeplink, Deeplink.trading(gridID: nil))
    }

    func testTradingGridTonLinkParsing() throws {
        let string = "ton://trading/most_traded"
        let parsedDeeplink = try parser.parse(string: string)
        XCTAssertEqual(parsedDeeplink, Deeplink.trading(gridID: "most_traded"))
    }

    func testTradeAssetTonLinkParsing() throws {
        let assetID = "ton/mainnet/jetton/0:abcdef"
        let string = "ton://assets/\(assetID)"
        let parsedDeeplink = try parser.parse(string: string)
        XCTAssertEqual(parsedDeeplink, Deeplink.tradeAsset(assetID: assetID))
    }

    func testBrowserTonLinkParsing() throws {
        let string = "ton://browser"
        let parsedDeeplink = try parser.parse(string: string)
        XCTAssertEqual(parsedDeeplink, Deeplink.browser(network: nil))
    }

    func testBrowserNetworkTonLinkParsing() throws {
        let string = "ton://browser?network=tron"
        let parsedDeeplink = try parser.parse(string: string)
        XCTAssertEqual(parsedDeeplink, Deeplink.browser(network: .tron))
    }

    func testBrowserNetworkTrxAliasParsing() throws {
        let string = "ton://browser?network=trx"
        let parsedDeeplink = try parser.parse(string: string)
        XCTAssertEqual(parsedDeeplink, Deeplink.browser(network: .tron))
    }

    func testBrowserUnknownNetworkParsing() throws {
        let string = "ton://browser?network=foo"
        let parsedDeeplink = try parser.parse(string: string)
        XCTAssertEqual(parsedDeeplink, Deeplink.browser(network: nil))
    }

    func testMigrationTonLinkParsing() throws {
        let string = "ton://migration"
        let parsedDeeplink = try parser.parse(string: string)
        XCTAssertEqual(parsedDeeplink, Deeplink.migration)
    }

    func testMigrateAliasParsing() throws {
        XCTAssertEqual(try parser.parse(string: "tonkeeprdemomode://migrate"), Deeplink.migration)
        XCTAssertEqual(try parser.parse(string: "ton://migrate"), Deeplink.migration)
    }

    func testMainTonLinkParsing() throws {
        let string = "ton://main"
        let parsedDeeplink = try parser.parse(string: string)
        XCTAssertEqual(parsedDeeplink, Deeplink.main)
    }

    func testMainTonLinkAppHostRootPath() throws {
        let string = "ton://"
        let parsedDeeplink = try parser.parse(string: string)
        XCTAssertEqual(parsedDeeplink, Deeplink.main)
    }

    func testWalletConnectRawURIParsing() throws {
        let uri = "wc:123@2?relay-protocol=irn&symKey=abc"
        let parsedDeeplink = try parser.parse(string: uri)
        XCTAssertEqual(
            parsedDeeplink,
            Deeplink.walletConnect(WalletConnectDeeplink(uri: uri, source: .deeplink))
        )
    }

    func testWalletConnectRawURIParsingUsesProvidedQRSource() throws {
        let uri = "wc:123@2?relay-protocol=irn&symKey=abc"
        let parsedDeeplink = try parser.parse(string: uri, source: .qr)
        XCTAssertEqual(
            parsedDeeplink,
            Deeplink.walletConnect(WalletConnectDeeplink(uri: uri, source: .qr))
        )
    }

    func testWalletConnectRawURIWithExpiryTimestampParsing() throws {
        let uri = "wc:d14c5131edc3120a50f9480701665bc2a4d9ca0d66684bb455ad184ce60cad3d@2?expiryTimestamp=1779080068&relay-protocol=irn&symKey=f4ddb9526260f561d3c87e66bf49cca0b50c02ca2120108fbfa15b31341a47d5"
        let parsedDeeplink = try parser.parse(string: uri)
        XCTAssertEqual(
            parsedDeeplink,
            Deeplink.walletConnect(WalletConnectDeeplink(uri: uri, source: .deeplink))
        )
    }

    func testWalletConnectRawURIParsingTrimsAndNormalizesScheme() throws {
        let uri = "wc:123@2?relay-protocol=irn&symKey=abc"
        let parsedDeeplink = try parser.parse(string: " \nWC:123@2?relay-protocol=irn&symKey=abc\t")
        XCTAssertEqual(
            parsedDeeplink,
            Deeplink.walletConnect(WalletConnectDeeplink(uri: uri, source: .deeplink))
        )
    }

    func testWalletConnectTonkeeprDemoModeDeeplinkParsing() throws {
        let uri = "wc:123@2?relay-protocol=irn&symKey=abc"
        let string = "tonkeeprdemomode://wc?uri=wc%3A123%402%3Frelay-protocol%3Dirn%26symKey%3Dabc"
        let parsedDeeplink = try parser.parse(string: string)
        XCTAssertEqual(
            parsedDeeplink,
            Deeplink.walletConnect(WalletConnectDeeplink(uri: uri, source: .deeplink))
        )
    }

    func testWalletConnectTonkeeprDemoModeDocsFormatDeeplinkParsing() throws {
        let uri = "wc:123@2?relay-protocol=irn&symKey=abc"
        let string = "tonkeeprdemomode://wc?uri=wc:123@2?relay-protocol=irn&symKey=abc"
        let parsedDeeplink = try parser.parse(string: string)
        XCTAssertEqual(
            parsedDeeplink,
            Deeplink.walletConnect(WalletConnectDeeplink(uri: uri, source: .deeplink))
        )
    }

    func testWalletConnectTonLinkParsing() throws {
        let uri = "wc:123@2?relay-protocol=irn&symKey=abc"
        let string = "ton://wc?uri=wc%3A123%402%3Frelay-protocol%3Dirn%26symKey%3Dabc"
        let parsedDeeplink = try parser.parse(string: string)
        XCTAssertEqual(
            parsedDeeplink,
            Deeplink.walletConnect(WalletConnectDeeplink(uri: uri, source: .deeplink))
        )
    }

    func testWalletConnectTonSchemeDocsFormatLinkParsing() throws {
        let uri = "wc:123@2?relay-protocol=irn&symKey=abc"
        let string = "ton://wc?uri=wc:123@2?relay-protocol=irn&symKey=abc"
        let parsedDeeplink = try parser.parse(string: string)
        XCTAssertEqual(
            parsedDeeplink,
            Deeplink.walletConnect(WalletConnectDeeplink(uri: uri, source: .deeplink))
        )
    }

    func testWalletConnectRawIncompleteURIIsIgnored() throws {
        XCTAssertThrowsError(try parser.parse(string: "wc:123@2")) { error in
            XCTAssertEqual(error as? DeeplinkParserError, .ignoredWalletConnectWakeUp)
        }
    }

    func testWalletConnectTonkeeprDemoModeIncompleteURIIsIgnored() throws {
        XCTAssertThrowsError(try parser.parse(string: "tonkeeprdemomode://wc?uri=wc%3A123%402")) { error in
            XCTAssertEqual(error as? DeeplinkParserError, .ignoredWalletConnectWakeUp)
        }
    }

    func testWalletConnectTonSchemeIncompleteURIIsIgnored() throws {
        XCTAssertThrowsError(try parser.parse(string: "ton://wc?uri=wc%3A123%402")) { error in
            XCTAssertEqual(error as? DeeplinkParserError, .ignoredWalletConnectWakeUp)
        }
    }

    func testWalletConnectWrappedIncompleteURIWithOuterQueryIsIgnored() throws {
        XCTAssertThrowsError(try parser.parse(string: "tonkeeprdemomode://wc?uri=wc%3A123%402&source=outer")) { error in
            XCTAssertEqual(error as? DeeplinkParserError, .ignoredWalletConnectWakeUp)
        }
    }

    func testWalletConnectTonLinkSessionRequestRedirectIsIgnored() {
        let string = "ton://wc?requestId=1787580460495163&sessionTopic=ac8d427e8f4c76c5cb1b8920d82a0944d910f5c3b96"
        XCTAssertThrowsError(try parser.parse(string: string)) { error in
            XCTAssertEqual(error as? DeeplinkParserError, .ignoredWalletConnectWakeUp)
        }
    }

    func testWalletConnectCustomSchemeSessionRequestRedirectIsIgnored() {
        let string = "tonkeeprdemomode://wc?requestId=1787580460495163&sessionTopic=ac8d427e8f4c76c5cb1b8920d82a0944d910f5c3b96"
        XCTAssertThrowsError(try parser.parse(string: string)) { error in
            XCTAssertEqual(error as? DeeplinkParserError, .ignoredWalletConnectWakeUp)
        }
    }

    func testWalletConnectTonSchemeSessionRequestRedirectIsIgnored() {
        XCTAssertThrowsError(try parser.parse(string: "ton://wc?sessionTopic=topic")) { error in
            XCTAssertEqual(error as? DeeplinkParserError, .ignoredWalletConnectWakeUp)
        }
    }

    func testWalletConnectMobSchemeSessionRequestRedirectIsIgnored() {
        XCTAssertThrowsError(try parser.parse(string: "tonkeepr-demo-mode-mob://wc?requestId=1787580460495163")) { error in
            XCTAssertEqual(error as? DeeplinkParserError, .ignoredWalletConnectWakeUp)
        }
    }

    func testWalletConnectSessionRequestRedirectWithTrailingSlashIsIgnored() {
        let string = "ton://wc/?requestId=1787580460495163&sessionTopic=topic"
        XCTAssertThrowsError(try parser.parse(string: string)) { error in
            XCTAssertEqual(error as? DeeplinkParserError, .ignoredWalletConnectWakeUp)
        }
    }

    func testWalletConnectContainerWithInvalidWrappedURIIsReported() {
        let string = "ton://wc?uri=notAWalletConnectURI"
        XCTAssertThrowsError(try parser.parse(string: string)) { error in
            XCTAssertEqual(
                error as? DeeplinkParserError,
                .unsupportedDeeplink(code: .notSupportedPath, string: string)
            )
        }
    }

    func testWalletConnectBareCustomSchemeRedirectIsIgnored() {
        XCTAssertThrowsError(try parser.parse(string: "tonkeeprdemomode://wc")) { error in
            XCTAssertEqual(error as? DeeplinkParserError, .ignoredWalletConnectWakeUp)
        }
    }

    func testWalletConnectBareTonSchemeRedirectIsIgnored() {
        XCTAssertThrowsError(try parser.parse(string: "ton://wc")) { error in
            XCTAssertEqual(error as? DeeplinkParserError, .ignoredWalletConnectWakeUp)
        }
    }

    func testWalletConnectRedirectWithUnknownQueryIsIgnored() {
        XCTAssertThrowsError(try parser.parse(string: "ton://wc?sessionTopic=")) { error in
            XCTAssertEqual(error as? DeeplinkParserError, .ignoredWalletConnectWakeUp)
        }
    }

    func testWalletConnectLinkModeEnvelopeIsIgnored() {
        let string = "ton://wc?wc_ev=eyJ0IjoiMSJ9&topic=abc"
        XCTAssertThrowsError(try parser.parse(string: string)) { error in
            XCTAssertEqual(error as? DeeplinkParserError, .ignoredWalletConnectWakeUp)
        }
    }

    func testWalletConnectDeepPathRedirectIsIgnored() {
        XCTAssertThrowsError(try parser.parse(string: "ton://wc/session/request")) { error in
            XCTAssertEqual(error as? DeeplinkParserError, .ignoredWalletConnectWakeUp)
        }
    }

    func testEthereumErc20TransferLinkParsing() throws {
        let contract = "0xdac17f958d2ee523a2206206994597c13d831ec7"
        let recipient = "0x8e23ee67d1332ad560396262c48ffbb01f93d052"

        let parsedDeeplink = try parser.parse(
            string: "ethereum:\(contract)@1/transfer?address=\(recipient)&uint256=1e6"
        )

        XCTAssertEqual(
            parsedDeeplink,
            .transfer(
                .evmSendTransfer(
                    Deeplink.EvmTransferData(
                        recipient: recipient,
                        asset: .erc20(contract: contract),
                        chain: .eth,
                        amount: BigUInt(1_000_000)
                    )
                )
            )
        )
    }

    func testEthereumNativeTransferLinkParsing() throws {
        let recipient = "0x8e23ee67d1332ad560396262c48ffbb01f93d052"

        let parsedDeeplink = try parser.parse(string: "ethereum:\(recipient)?value=2.014e18")

        XCTAssertEqual(
            parsedDeeplink,
            .transfer(
                .evmSendTransfer(
                    Deeplink.EvmTransferData(
                        recipient: recipient,
                        asset: .native,
                        chain: nil,
                        amount: BigUInt("2014000000000000000")
                    )
                )
            )
        )
    }

    func testUnsupportedEthereumLinkStaysUnsupported() throws {
        XCTAssertThrowsError(
            try parser.parse(string: "ethereum:0xdac17f958d2ee523a2206206994597c13d831ec7@137")
        ) { error in
            XCTAssertEqual(
                error as? DeeplinkParserError,
                .unsupportedDeeplink(
                    code: .invalidPrefix,
                    string: "ethereum:0xdac17f958d2ee523a2206206994597c13d831ec7@137"
                )
            )
        }
    }
}
