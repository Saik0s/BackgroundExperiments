//
// BackgroundTaskManager.swift
//

import ActivityKit
import BackgroundTasks
import Common
import Foundation
import UIKit
import UniformTypeIdentifiers

@Observable
class BackgroundTaskManager {
  static let shared = BackgroundTaskManager()

  var notificationManager = NotificationManager()

  var isTaskRunning = false
  let taskDuration = 600.0 // 10 minutes

  var startTime: Date {
    didSet {
      UserDefaults.standard.set(startTime.timeIntervalSince1970, forKey: "startTime")
    }
  }

  var elapsedTime: Double {
    didSet {
      UserDefaults.standard.set(elapsedTime, forKey: "elapsedTime")
    }
  }

  var progress: Double { elapsedTime / taskDuration }

  private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid

  let fileURL = URL.documentsDirectory.appendingPathComponent("TaskLog.txt")
  private let processingTaskIdentifier = "me.igortarasenko.BackgroundExperimentsApp"

  init() {
    startTime = Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: "startTime"))
    elapsedTime = UserDefaults.standard.double(forKey: "elapsedTime")
  }

  func startTask() {
    logs.log("Task started")
    isTaskRunning = true
    notificationManager.startNotificationsLoop()
    performHeavyTask()
  }

  func resetTask() {
    logs.log("Task reset")
    isTaskRunning = false
    startTime = Date()
    elapsedTime = 0.0
    endBackgroundExecution()
    cancelScheduledBackgroundProcessingTask()
    try? FileManager.default.removeItem(at: fileURL)
  }

  func requestBackgroundExecution() {
    backgroundTaskID = UIApplication.shared.beginBackgroundTask {
      self.endBackgroundExecution()
    }
  }

  func endBackgroundExecution() {
    logs.log("Ending background execution")
    if backgroundTaskID != .invalid {
      UIApplication.shared.endBackgroundTask(backgroundTaskID)
      backgroundTaskID = .invalid
    }
  }

  func registerForProcessingTask() {
    logs.log("Registering for processing task")
    BGTaskScheduler.shared.register(forTaskWithIdentifier: processingTaskIdentifier, using: nil) { task in
      guard let task = task as? BGProcessingTask else { return }
      self.handleBGProcessingTask(bgTask: task)
    }
  }

  func scheduleBackgroundProcessingTask() {
    logs.log("Scheduling background processing task")
    let request = BGProcessingTaskRequest(identifier: processingTaskIdentifier)
    request.requiresNetworkConnectivity = false
    request.requiresExternalPower = false
    request.earliestBeginDate = Date(timeIntervalSinceNow: 1)

    do {
      try BGTaskScheduler.shared.submit(request)
    } catch {
      logs.log("Could not schedule background task: \(error)")
    }
  }

  func cancelScheduledBackgroundProcessingTask() {
    logs.log("Cancelling scheduled background processing task")
    BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: processingTaskIdentifier)
  }

  private func handleBGProcessingTask(bgTask: BGProcessingTask) {
    logs.log("Handling background processing task")
    let task = Task {
      startTask()
      try await Task.sleep(for: .seconds(1))
      while isTaskRunning {
        try await Task.sleep(for: .seconds(1))
      }
    }

    bgTask.expirationHandler = {
      logs.log("Background processing task expired")
      task.cancel()
    }
  }

  private func performHeavyTask() {
    logs.log("Performing heavy task")
    startTime = Date()
    performIteration()
  }

  private func performIteration() {
    guard isTaskRunning else {
      logs.log("Task is not running")
      return
    }

    guard elapsedTime < taskDuration else {
      logs.log("Elapsed time: \(elapsedTime)")
      logs.log("Task duration: \(taskDuration)")
      logs.log("Task is going to reset")
      resetTask()
      return
    }

    let fileManager = FileManager.default
    if !fileManager.fileExists(atPath: fileURL.path) {
      fileManager.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
    }

    var existingContent = ""
    do {
      existingContent = try String(contentsOf: fileURL, encoding: .utf8)
    } catch {
      logs.log("Failed to read existing file contents: \(error.localizedDescription)")
    }

    let currentTime = Date()
    elapsedTime = currentTime.timeIntervalSince(startTime)
    let logEntry = "\(Int(elapsedTime)) seconds elapsed\n"
    let newContent = existingContent + logEntry
    do {
      try newContent.write(to: fileURL, atomically: true, encoding: .utf8)
    } catch {
      logs.log("Failed to write to file: \(error.localizedDescription)")
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      self.performIteration()
    }

    logs.log("Elapsed time: \(elapsedTime)")

    ActivityManager.shared.updateActivity(progress: progress, state: .running)
  }
}
