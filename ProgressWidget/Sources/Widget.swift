//
// Widget.swift
//

import Common
import SwiftUI
import WidgetKit

// MARK: - ProgressWidgetEntryView

struct ProgressWidgetEntryView: View {
  var state: ProgressAttributes.ContentState

  var body: some View {
    VStack {
      Text("Task Progress")
        .font(.headline)

      ProgressView(value: state.progress)
        .progressViewStyle(LinearProgressViewStyle())

      Text(state.state.rawValue)
        .font(.subheadline)
    }
    .padding()
  }
}

// MARK: - ProgressWidget

@main
struct ProgressWidget: Widget {
  private let kind: String = "ProgressWidget"

  var body: some WidgetConfiguration {
    ActivityConfiguration(for: ProgressAttributes.self) { context in
      ProgressWidgetEntryView(state: context.state)
    } dynamicIsland: { context in
      DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          Text("Task Progress")
        }
        DynamicIslandExpandedRegion(.trailing) {
          Text(context.state.state.rawValue)
        }
        DynamicIslandExpandedRegion(.bottom) {
          ProgressView(value: context.state.progress)
            .progressViewStyle(LinearProgressViewStyle())
        }
      } compactLeading: {
        Text("Task Progress")
      } compactTrailing: {
        Text(String(format: "%.0f%%", context.state.progress * 100))
      } minimal: {
        Text(String(format: "%.0f%%", context.state.progress * 100))
      }
    }
  }
}
