//
// AppApp.swift
//

import SwiftUI

@main
struct AppApp: App {
  init() {
    BackgroundTaskManager.shared.registerForProcessingTask()
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
