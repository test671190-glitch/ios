import FirebaseCore
import FirebaseMessaging
import Foundation

public final class PushNotificationTokenProvider: NSObject, MessagingDelegate {
    public var didUpdateToken: ((String?) -> Void)?

    public func setup() {
        guard FirebaseApp.app() != nil else { return }
        Messaging.messaging().delegate = self
    }

    public func getToken() async -> String? {
        guard FirebaseApp.app() != nil else { return nil }
        try? await Messaging.messaging().token()
    }

    public func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        didUpdateToken?(fcmToken)
    }
}
