//
//  NotificationManager.swift
//  TimeOnTask
//

import UserNotifications
#if os(macOS)
import AppKit
#endif

final class NotificationManager {
    /// Singleton notification helper used by the timer engine.
    static let shared = NotificationManager()

    /// Creates the singleton notification manager.
    private init() {}

    /// Requests user notification authorization if the system has not prompted yet.
    func requestAuthorizationIfNeeded() {
        // System notification center used to inspect and request alert permissions.
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .notDetermined else { return }
            center.requestAuthorization(options: [.alert, .sound]) { _, _ in }
        }
    }

    /// Sends the completion notification and plays the completion sound.
    ///
    /// - Parameters:
    ///   - label: The optional session label to include in the notification body.
    ///   - minutes: The completed session length in whole minutes.
    func notifySessionComplete(label: String, minutes: Int) {
        // Notification payload shown when a timer session completes.
        let content = UNMutableNotificationContent()
        content.title = "Session complete"
        content.body = label.isEmpty ? "\(minutes) minutes done." : "\(label) — \(minutes) minutes done."
        content.sound = .default

        // One-off notification request delivered immediately.
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)

#if os(macOS)
        NSSound(named: "Glass")?.play()
#endif
    }
}
