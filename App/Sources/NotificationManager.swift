//
// NotificationManager.swift
//

import Foundation
import UserNotifications

@Observable
class NotificationManager {
  private var notificationTimer: Timer?

  var logs: [String] = []

  private let date = Date()

  func scheduleNotification() async {
    print("Going to schedule notification")
    logs.append("Going to schedule notification")

    let settings = await UNUserNotificationCenter.current().notificationSettings()
    if settings.authorizationStatus != .authorized {
      logs.append("Notifications not determined, requesting authorization")
      do {
        try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
      } catch {
        logs.append("Error requesting notification authorization: \(error.localizedDescription)")
        return
      }
    }

    let content = UNMutableNotificationContent()
    content.title = "App Terminated"
    content.body = "Total run time: \(date.distance(to: Date())) seconds"
    content.sound = UNNotificationSound.default

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
    let request = UNNotificationRequest(identifier: "TestNotification", content: content, trigger: trigger)

    do {
      try await UNUserNotificationCenter.current().add(request)
      print("Notification scheduled successfully")
      logs.append("Notification scheduled successfully")
    } catch {
      print("Error scheduling notification: \(error.localizedDescription)")
      logs.append("Error scheduling notification: \(error.localizedDescription)")
    }

    do {
      try await Task.sleep(for: .seconds(9))
      print("Timer hit")
      cancelNotification()
      await scheduleNotification()
    } catch {
      print("Error sleeping: \(error.localizedDescription)")
      logs.append("Error sleeping: \(error.localizedDescription)")
    }
  }

  func cancelNotification() {
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["TestNotification"])
    print("Notification cancelled")
    logs.append("Notification cancelled")
  }
}
