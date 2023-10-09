//
//  MusicViewModel.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/05.
//

import Alamofire
import AVFoundation
import AVKit
import Combine
import Foundation
import SwiftUI

// MARK: - MusicViewModel

@MainActor
class MusicViewModel: ObservableObject {
  private var timer: Timer?
  @Published var url: URL?
  @Published var isPlaying = false
  @Published public var soundSamples = [MusicNote]()
  /// 오디오를 샘플링하기 위한 count
  @Published var sample_count = 10
  @Published var trimDuration: Double = 15
  @Published var player: AVPlayer?
  @Published var session: AVAudioSession?

  @Published var musicInfo: Music?
  @Published var isTrimmed = false
  @Published var startTime: Double?
  @Published var musicVolume: Float = 1.0

  /// 샘플링된 정보를 배열에 저장할 때 필요한 index
  var index = 0

  var dataManager: MusicServiceProtocol

  init(dataManager: MusicServiceProtocol = MusicService.shared) {
    self.dataManager = dataManager

    // AudioSession의 카테고리를 playback으로 설정하고, 오디오 출력은 기존의 포트를 사용합니다.
    do {
      session = AVAudioSession.sharedInstance()
      try session?.setCategory(.playback)
      try session?.overrideOutputAudioPort(.none)

    } catch {
      print(error.localizedDescription)
    }
  }
}

extension MusicViewModel {
  func startTimer() {
    count_duration { duration in
      let time_interval = duration / Double(self.sample_count)
      self.timer = Timer.scheduledTimer(withTimeInterval: time_interval * self.trimDuration / 10, repeats: true, block: { _ in
        if self.index < self.soundSamples.count {
//          withAnimation(.linear) {
//            self.soundSamples[self.index].color = Color.Secondary_Default
//          }
          self.index += 1
        }
      })
    }
  }

  /// 오디오 파일의 총 시간을 계산합니다. 백그라운드에서 동작합니다.
  /// - Parameter completion: 오디오 파일 재생 시간을 알아내고, 해당 재생 시간을 콜백으로 전달합니다.
  func count_duration(completion: @escaping (Float64) -> Void) {
    DispatchQueue.global(qos: .background).async {
      Task {
        if let duration = try await self.player?.currentItem?.asset.load(.duration) {
          let seconds = CMTimeGetSeconds(duration)
          DispatchQueue.main.async {
            completion(seconds)
          }
          return
        }

        DispatchQueue.main.async {
          completion(1)
        }
      }
    }
  }

  func visualizeAudio() async {
    if let url {
      let results = try? await dataManager.buffer(url: url, samplesCount: sample_count)
      DispatchQueue.main.async {
        self.soundSamples = results ?? []
      }
    }
  }

  func playAudio(startTime: Double) {
    if isPlaying {
      pauseAudio()
    } else {
      player = AVPlayer(url: url!)
      player?.volume = musicVolume
      let start = CMTime(seconds: startTime, preferredTimescale: 1000)
      player?.seek(to: start) // 시작 시간으로 이동
      player?.play()
      startTimer()
      count_duration { _ in }
      DispatchQueue.main.async {
        self.isPlaying.toggle()
      }
    }
  }

  func setVolume(value: Float) {
//    pauseAudio()
    musicVolume = value
  }

  func pauseAudio() {
    player?.pause()
    timer?.invalidate()
    DispatchQueue.main.async {
      self.isPlaying = false
    }
  }

  func stopAudio() {
    print("Audio Stopped")
    player?.pause()
    timer?.invalidate()
    DispatchQueue.main.async {
      self.isPlaying = false
    }
    player = nil
  }

  @objc
  func playerDidFinishPlaying(note _: NSNotification) {
    player?.pause()
    player?.seek(to: .zero)
    timer?.invalidate()
    DispatchQueue.main.async {
      self.isPlaying = false
    }
    index = 0
    soundSamples = soundSamples.map { tmp -> MusicNote in
      var cur = tmp
      cur.color = Color.gray
      return cur
    }
  }

  func removeAudio() {
    do {
      if let url {
        try FileManager.default.removeItem(at: url)
      }
    } catch {
      print(error)
    }
  }

  func removeMusic() {
    url = nil
    player = nil
    session = nil
    musicInfo = nil
    isTrimmed = false
    isPlaying = false
    startTime = nil
    musicVolume = 1.0
  }
}
