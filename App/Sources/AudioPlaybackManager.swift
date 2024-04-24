//
// AudioPlaybackManager.swift
//

import AVFoundation

class AudioPlaybackManager {
  var audioPlayer: AVAudioPlayer?

  func startPlayingSilence() {
    let silenceURL = Bundle.main.url(forResource: "silence", withExtension: "mp3")!
    do {
      audioPlayer = try AVAudioPlayer(contentsOf: silenceURL)
      audioPlayer?.play()
    } catch {
      print("Failed to play silence: \(error.localizedDescription)")
    }
  }

  func stopPlaying() {
    audioPlayer?.stop()
  }
}
