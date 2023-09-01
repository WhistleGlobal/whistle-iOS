//
//  MusicTrimView.swift
//  Whistle
//
//  Created by 박상원 on 2023/08/31.
//

import AVFoundation
import SwiftUI

// MARK: - MusicTrimView

struct MusicTrimView: View {

  // MARK: Internal

  var body: some View {
    VStack {
      Text("Audio Trimmer")
        .font(.title)
        .padding()

      if let audioURL {
        AudioPlayerView(audioURL: audioURL)
          .padding()

        HStack {
          Text("Start Time: \(startTime, specifier: "%.2f")")
          Slider(value: $startTime, in: 0 ... endTime)
        }
        .padding()

        HStack {
          Text("End Time: \(endTime, specifier: "%.2f")")
          Slider(value: $endTime, in: startTime ... audioDuration(audioURL))
        }
        .padding()

        Button(action: {
          isTrimming = true
          trimAudio()
        }) {
          Text("Trim Audio")
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
        }
        .padding()
      } else {
        Text("Select an audio file...")
          .padding()
      }
      Button(action: {
        playTrimmedAudio()
      }) {
        Text(isPlaying ? "Pause" : "Play Trimmed Audio")
          .foregroundColor(.white)
          .padding()
          .background(Color.green)
          .cornerRadius(10)
      }
      .padding()
      Spacer()
    }
    .onAppear {
      loadAudioFile()
    }
  }

  func loadAudioFile() {
    if let audioFileURL = Bundle.main.url(forResource: "newjeans", withExtension: "mp3") {
      audioURL = audioFileURL
      endTime = audioDuration(audioFileURL)
    }
  }

  func audioDuration(_ url: URL) -> TimeInterval {
    let asset = AVURLAsset(url: url)
    return TimeInterval(asset.duration.seconds)
  }

  func trimAudio() {
    guard let audioURL else {
      return
    }

    let asset = AVURLAsset(url: audioURL)

    let startTime = CMTime(seconds: startTime, preferredTimescale: 1000)
    let endTime = CMTime(seconds: endTime, preferredTimescale: 1000)
    let timeRange = CMTimeRange(start: startTime, end: endTime)

    let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A)
    exportSession?.outputFileType = .m4a

    let outputPath = FileManager.default.temporaryDirectory.appendingPathComponent("trimmedAudio.m4a")

    // Delete existing file if it exists
    if FileManager.default.fileExists(atPath: outputPath.path) {
      do {
        try FileManager.default.removeItem(at: outputPath)
      } catch {
        print("Error deleting existing file: \(error)")
        return
      }
    }

    exportSession?.outputURL = outputPath
    exportSession?.timeRange = timeRange

    exportSession?.exportAsynchronously(completionHandler: {
      DispatchQueue.main.async {
        isTrimming = false
        trimmedAudioURL = outputPath
        print(trimmedAudioURL)
        // Handle export completion, error, or success here.
      }
    })
  }

  func playTrimmedAudio() {
    guard let trimmedAudioURL else {
      print("ERRR")
      return
    }

    print(trimmedAudioURL)
    if isPlaying {
      player?.pause()
    } else {
      let playerItem = AVPlayerItem(url: trimmedAudioURL)
      player = AVPlayer(playerItem: playerItem)
      player?.play()
    }

    isPlaying.toggle()
  }

  // MARK: Private

  @State private var audioURL: URL?
  @State private var startTime: TimeInterval = 0
  @State private var endTime: TimeInterval = 0
  @State private var isTrimming = false
  @State private var isPlaying = false
  @State private var trimmedAudioURL: URL?
  @State private var player: AVPlayer?

}

// MARK: - AudioPlayerView

struct AudioPlayerView: View {

  // MARK: Internal

  var audioURL: URL

  var body: some View {
    VStack {
      Text("Audio Player")
        .font(.title)
        .padding()

      if let player {
        Text(isPlaying ? "Playing" : "Paused")
          .foregroundColor(isPlaying ? .green : .red)
          .padding()

        Button(action: {
          if isPlaying {
            player.pause()
          } else {
            player.play()
          }
          isPlaying.toggle()
        }) {
          Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
            .font(.system(size: 50))
            .foregroundColor(.blue)
        }
        .padding()
      }
    }
    .onAppear {
      setupPlayer()
    }
    .onDisappear {
      player?.pause()
    }
  }

  func setupPlayer() {
    let playerItem = AVPlayerItem(url: audioURL)
    player = AVPlayer(playerItem: playerItem)

    // Add observers or additional setup if needed
  }

  // MARK: Private

  @State private var player: AVPlayer?
  @State private var isPlaying = false
}

// MARK: - MusicTrimView_Previews

struct MusicTrimView_Previews: PreviewProvider {
  static var previews: some View {
    MusicTrimView()
  }
}