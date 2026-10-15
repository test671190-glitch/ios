import Foundation
import KeeperCore

enum ReceiptValidationType {
    case sandbox
    case production

    var urlString: String {
        switch self {
        case .sandbox:
            ""
        case .production:
            ""
        }
    }

    var url: URL {
        URL(string: urlString) ?? .noServer
    }
}
