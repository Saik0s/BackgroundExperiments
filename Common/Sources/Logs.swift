//
// Logs.swift
//

import Foundation
import Observation
import os

public let logs = Logs.shared

// MARK: - Logs

@Observable
public class Logs {
  public static var shared: Logs = .init()

  public var logs: [String] = []

  public static let url = URL.documentsDirectory.appendingPathComponent("logs.log")

  @ObservationIgnored private let oslogger: os.Logger = .init(subsystem: "BackgroundExperiments", category: "General")
  @ObservationIgnored private let fileStream: FileHandlerOutputStream = try! .init(localFile: Logs.url)

  init() {
    do {
      let logData = try Data(contentsOf: Self.url)
      let logString = String(data: logData, encoding: .utf8) ?? ""
      logs = logString.components(separatedBy: .newlines).filter { !$0.isEmpty }
    } catch {
      oslogger.error("Failed to read log file: \(error.localizedDescription)")
    }
  }

  public func log(_ values: Any..., file: String = #file, function: String = #function, line: UInt = #line) {
    let valuesString = values.map { "\($0)" }.joined(separator: " ")
    let timestamp = Date().formatted(date: .omitted, time: .standard)
    let message = "\(timestamp) \(file.lastPathComponent):\(line) \(function) \(valuesString)"
    oslogger.info("\(message)")
    logs.append(message)
    fileStream.write(message)
  }

  public func cleanupLogs() {
    logs = []
    fileStream.cleanup()
  }
}

// MARK: - FileHandlerOutputStream

struct FileHandlerOutputStream: TextOutputStream {
  private let fileHandle: FileHandle
  private let encoding: String.Encoding

  init(localFile url: URL, encoding: String.Encoding = .utf8) throws {
    if !FileManager.default.fileExists(atPath: url.path) {
      guard FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil) else {
        throw NSError(domain: "FileHandlerOutputStream", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not create file at \(url.path)"])
      }
    }

    let fileHandle = try FileHandle(forWritingTo: url)
    fileHandle.seekToEndOfFile()
    self.fileHandle = fileHandle
    self.encoding = encoding
  }

  func write(_ string: String) {
    if let data = string.data(using: encoding) {
      fileHandle.write(data)
    }
  }

  func cleanup() {
    do {
      try fileHandle.truncate(atOffset: 0)
    } catch {
      print("Failed to truncate file at offset: \(error.localizedDescription)")
    }
  }
}

extension String {
  var lastPathComponent: String {
    components(separatedBy: "/").last ?? self
  }
}
