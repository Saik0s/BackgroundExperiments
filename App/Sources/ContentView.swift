//
// ContentView.swift
//

import ActivityKit
import Common
import SwiftUI

struct ContentView: View {
//  @State private var notificationManager = NotificationManager()
  @State private var backgroundTaskManager = BackgroundTaskManager.shared
  @State private var activityManager = ActivityManager()
  @State private var audioPlaybackManager = AudioPlaybackManager()
  @State var showLogs = false

  var body: some View {
    VStack {
      VStack(alignment: .leading) {
        Label {
          Text(backgroundTaskManager.isTaskRunning ? "Task is running" : "Task is not running")
            .font(.headline)
        } icon: {
          Image(systemName: backgroundTaskManager.isTaskRunning ? "bolt.fill" : "bolt.slash.fill")
            .foregroundColor(backgroundTaskManager.isTaskRunning ? .green : .red)
        }

        Label {
          Text("\(backgroundTaskManager.elapsedTime) seconds elapsed")
            .font(.subheadline)
        } icon: {
          Image(systemName: "clock")
            .foregroundColor(.blue)
        }

        Label {
          Text("\(backgroundTaskManager.progress * 100, specifier: "%.0f")% complete")
            .font(.subheadline)
        } icon: {
          Image(systemName: "chart.bar.fill")
            .foregroundColor(.orange)
        }
      }

      Button(activityManager.isActivityRunning ? "End Activity" : "Start Activity") {
        if activityManager.isActivityRunning {
          activityManager.endActivity()
        } else {
          activityManager.startActivity()
        }
      }

      Button(backgroundTaskManager.isTaskRunning ? "Reset Task..." : "Start Task") {
        if backgroundTaskManager.isTaskRunning {
          backgroundTaskManager.resetTask()
        } else {
          backgroundTaskManager.startTask()
          // UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
        }
      }

      // Button(action: {
      //   Task {
      //     await notificationManager.scheduleNotification()
      //   }
      // }) {
      //   Text("Schedule Notification")
      // }

      Button(audioPlaybackManager.isPlaying ? "Stop Playing..." : "Start Playing") {
        if audioPlaybackManager.isPlaying {
          audioPlaybackManager.stopPlaying()
        } else {
          audioPlaybackManager.startPlaying()
        }
      }

      HStack {
        Button("Show Logs") {
          showLogs.toggle()
        }
        Button("Clear Logs") {
          logs.cleanupLogs()
        }
      }

      HStack {
        ShareLink("Share app logs", item: Logs.url)
        ShareLink("Share task logs", item: backgroundTaskManager.fileURL)
      }
    }
    .buttonStyle(.borderedProminent)
    .frame(maxHeight: .infinity)
    .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
      backgroundTaskManager.requestBackgroundExecution()
      backgroundTaskManager.scheduleBackgroundProcessingTask()
    }
    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
      backgroundTaskManager.endBackgroundExecution()
      backgroundTaskManager.cancelScheduledBackgroundProcessingTask()
    }
    .sheet(isPresented: $showLogs) {
      ScrollView {
        LazyVStack(spacing: 0) {
          ForEach(Array(logs.logs.enumerated()), id: \.offset) { offset, value in
            Text(value)
              .font(.footnote)
              .multilineTextAlignment(.leading)
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(2)
              .background(Color(offset % 2 == 0 ? .secondarySystemBackground : .systemBackground))
          }
        }
      }
      .presentationDetents([.medium, .large])
    }
  }
}
