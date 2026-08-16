//
//  NotificationManager.swift
//  TimeOnTask
//

import AppKit
import UserNotifications

final class NotificationManager {
    // Singleton notification helper used by the timer engine.
    static let shared = NotificationManager()

    private init() {}

    func requestAuthorizationIfNeeded() {
        // System notification center used to inspect and request alert permissions.
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .notDetermined else { return }
            center.requestAuthorization(options: [.alert, .sound]) { _, _ in }
        }
    }

    func notifySessionComplete(label: String, minutes: Int) {
        // Notification payload shown when a timer session completes.
        let content = UNMutableNotificationContent()
        content.title = "Session complete"
        content.body = label.isEmpty ? "\(minutes) minutes done." : "\(label) — \(minutes) minutes done."
        content.sound = .default

        // One-off notification request delivered immediately.
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)

        NSSound(named: "Glass")?.play()
    }
}
