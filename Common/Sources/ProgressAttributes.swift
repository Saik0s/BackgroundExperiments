//
// ProgressAttributes.swift
//

import ActivityKit

// MARK: - ProgressAttributes

public struct ProgressAttributes: ActivityAttributes {
  public typealias ContentState = ProgressState

  public struct ProgressState: Codable, Hashable {
    public var progress: Double
    public var state: ActivityState

    public enum ActivityState: String, Codable {
      case running = "Running"
      case completed = "Completed"
    }

    public init(progress: Double = 0, state: ActivityState = .running) {
      self.progress = progress
      self.state = state
    }
  }

  public init() {}
}
