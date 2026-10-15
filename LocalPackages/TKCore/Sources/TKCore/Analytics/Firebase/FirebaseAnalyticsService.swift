import FirebaseAnalytics
import FirebaseCore
import Foundation

final class FirebaseAnalyticsService: AnalyticsService {
    init() {}

    func logEvent(name: String, args: [String: Any]) {
        guard FirebaseApp.app() != nil else { return }
        Analytics.logEvent(name, parameters: args)
    }
}
