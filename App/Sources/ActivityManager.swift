//
// ActivityManager.swift
//

import ActivityKit
import Common
import Foundation

// MARK: - ActivityManager

class ActivityManager {
  static let shared = ActivityManager()

  var isActivityRunning: Bool {
    activity != nil
  }

  private var activity: Activity<ProgressAttributes>?

  func startActivity() {
    let attributes = ProgressAttributes()
    let contentState = ProgressAttributes.ContentState(progress: 0, state: .running)

    do {
      activity = try Activity<ProgressAttributes>.request(
        attributes: attributes,
        contentState: contentState
//        content: ActivityContent(state: contentState, staleDate: nil)
      )
      print("Live Activity started")
    } catch {
      print("Error starting Live Activity: \(error.localizedDescription)")
    }
  }

  func updateActivity(progress: Double, state: ProgressAttributes.ContentState.ActivityState) {
    let contentState = ProgressAttributes.ContentState(progress: progress, state: state)

    Task {
      await activity?.update(using: contentState)
    }
  }

  func endActivity() {
    Task {
      await activity?.end(dismissalPolicy: .immediate)
      activity = nil
      print("Live Activity ended")
    }
  }
}
