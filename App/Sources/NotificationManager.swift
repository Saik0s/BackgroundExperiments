//
// NotificationManager.swift
//

import Common
import Foundation
import UserNotifications

@Observable
class NotificationManager {
  func startNotificationsLoop() {
    Task {
      await scheduleNotification()
    }
  }

  func scheduleNotification() async {
    logs.log("Going to schedule notification")

    let settings = await UNUserNotificationCenter.current().notificationSettings()
    if settings.authorizationStatus != .authorized {
      logs.log("Notifications not determined, requesting authorization")
      do {
        try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
      } catch {
        logs.log("Error requesting notification authorization: \(error.localizedDescription)")
        return
      }
    }

    let content = UNMutableNotificationContent()
    content.title = "App Terminated"
    content.body = "Total elapsed time: \(BackgroundTaskManager.shared.elapsedTime) seconds"
    content.sound = UNNotificationSound.default

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
    let request = UNNotificationRequest(identifier: "TestNotification", content: content, trigger: trigger)

    do {
      try await UNUserNotificationCenter.current().add(request)
      logs.log("Notification scheduled successfully")
    } catch {
      logs.log("Error scheduling notification: \(error.localizedDescription)")
    }

    do {
      try await Task.sleep(for: .seconds(2))
      cancelNotification()
      await scheduleNotification()
    } catch {
      logs.log("Error sleeping: \(error.localizedDescription)")
    }
  }

  func cancelNotification() {
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["TestNotification"])
    logs.log("Notification cancelled")
  }
}
