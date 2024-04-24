//
// AudioPlaybackManager.swift
//

import AVFoundation
import Common

@Observable
class AudioPlaybackManager {
  var isPlaying = false

  private var audioPlayer: AVAudioPlayer?

  init() {}

  func startPlaying() {
    let silenceURL = CommonResources.bundle.url(forResource: "jfk", withExtension: "wav")!
    do {
      audioPlayer = try AVAudioPlayer(contentsOf: silenceURL)
      audioPlayer?.play()
      isPlaying = true
    } catch {
      print("Failed to play silence: \(error.localizedDescription)")
    }
  }

  func stopPlaying() {
    audioPlayer?.stop()
    isPlaying = false
  }
}
