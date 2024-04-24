//
// ContentView.swift
//

import ActivityKit
import SwiftUI

struct ContentView: View {
  @State private var notificationManager = NotificationManager()
  @State private var backgroundTaskManager = BackgroundTaskManager.shared

  @State var activityManager = ActivityManager()
  @State var activeIslands: Int = 0

  var body: some View {
    VStack {
      Text(backgroundTaskManager.isTaskRunning ? "Task is running" : "Task is not running")
        .padding()

      Text("\(backgroundTaskManager.elapsedTime) seconds elapsed")
      Text("\(backgroundTaskManager.progress * 100, specifier: "%.0f")% complete")

      Button(action: {
        if backgroundTaskManager.isTaskRunning {
          backgroundTaskManager.resetTask()
          ActivityManager.shared.endActivity()
        } else {
          backgroundTaskManager.startTask()
          ActivityManager.shared.startActivity()
          UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
        }
      }) {
        Text(backgroundTaskManager.isTaskRunning ? "Reset Task" : "Start Task")
          .padding()
          .background(Color.blue)
          .foregroundColor(.white)
          .cornerRadius(10)
      }

      Button(action: {
        Task {
          await notificationManager.scheduleNotification()
        }
      }) {
        Text("Schedule Notification")
          .padding()
          .background(Color.green)
          .foregroundColor(.white)
          .cornerRadius(10)
      }

      ScrollView {
        VStack(alignment: .leading, spacing: 0) {
          ForEach(Array(notificationManager.logs.enumerated()), id: \.offset) { _, value in
            Text(value)
              .font(.footnote)
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      }
      .frame(height: 200)
      .background(Color(.secondarySystemBackground))
      .clipShape(RoundedRectangle(cornerRadius: 10))
      .padding(.horizontal)
    }
    .frame(maxHeight: .infinity)
    .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
      backgroundTaskManager.requestBackgroundExecution()
    }
    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
      backgroundTaskManager.isTaskRunning = backgroundTaskManager.isTaskRunning
    }
  }
}
