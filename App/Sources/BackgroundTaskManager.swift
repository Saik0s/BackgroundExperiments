//
// BackgroundTaskManager.swift
//

import ActivityKit
import BackgroundTasks
import Foundation
import UIKit
import UniformTypeIdentifiers

@Observable
class BackgroundTaskManager {
  static let shared = BackgroundTaskManager()

  var isTaskRunning = false
  var startTime = Date()
  let taskDuration = 300.0 // 5 minutes
  var elapsedTime = 0.0
  var progress: Double { elapsedTime / taskDuration }

  private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid

  private let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("TaskLog.txt")

  func startTask() {
    print("Task started")
    isTaskRunning = true
    startTime = Date()
    requestBackgroundExecution()
    performHeavyTask()
  }

  func resetTask() {
    print("Task reset")
    isTaskRunning = false
    endBackgroundExecution()
  }

  func requestBackgroundExecution() {
    backgroundTaskID = UIApplication.shared.beginBackgroundTask {
      self.endBackgroundExecution()
    }
  }

  private func endBackgroundExecution() {
    print("Ending background execution")
    if backgroundTaskID != .invalid {
      UIApplication.shared.endBackgroundTask(backgroundTaskID)
      backgroundTaskID = .invalid
    }
  }

  private func performHeavyTask() {
    print("Performing heavy task")
    startTime = Date()
    performIteration()
  }

  private func performIteration() {
    guard isTaskRunning else {
      print("Task is not running")
      return
    }

    guard elapsedTime < taskDuration else {
      print("Elapsed time: \(elapsedTime)")
      print("Task duration: \(taskDuration)")
      print("Task is going to reset")
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
      print("Failed to read existing file contents: \(error.localizedDescription)")
    }

    let currentTime = Date()
    elapsedTime = currentTime.timeIntervalSince(startTime)
    let logEntry = "\(Int(elapsedTime)) seconds elapsed\n"
    let newContent = existingContent + logEntry
    do {
      try newContent.write(to: fileURL, atomically: true, encoding: .utf8)
    } catch {
      print("Failed to write to file: \(error.localizedDescription)")
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      self.performIteration()
    }

    print("Elapsed time: \(elapsedTime)")

    ActivityManager.shared.updateActivity(progress: progress, state: .running)
  }
}
