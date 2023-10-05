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
//  private var downloadedAudioURL: URL?
  @Published var url: URL?
  @Published var isPlaying = false
  @Published public var soundSamples = [MusicNote]()
  /// 오디오를 샘플링하기 위한 count
  @Published var sample_count = 10
  @Published var trimmedDuration: Double = 15
  @Published var player: AVPlayer?
  @Published var session: AVAudioSession?

  /// 샘플링된 정보를 배열에 저장할 때 필요한 index
  var index = 0
  /// 오디오 url
//  let url: URL?

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

      self.timer = Timer.scheduledTimer(withTimeInterval: time_interval * 1.5, repeats: true, block: { _ in
        if self.index < self.soundSamples.count {
          withAnimation(.linear) {
            self.soundSamples[self.index].color = Color.Secondary_Default
          }
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

  func playAudio(startTime: Double, endTime: Double) {
    if isPlaying {
      pauseAudio()
    } else {
      player = AVPlayer(url: url!)
      let startTime = CMTime(seconds: startTime, preferredTimescale: 1)
      let endTime = CMTime(seconds: endTime, preferredTimescale: 1)
      player?.seek(to: startTime) // 시작 시간으로 이동
      player?.play()

      startTimer()
      count_duration { _ in }

      // 특정 시간 범위까지 재생 후 시작 시간으로 이동하는 클로저를 등록
      player?.addBoundaryTimeObserver(forTimes: [NSValue(time: endTime)], queue: .main) {
        [weak self] in
        self?.player?.seek(to: startTime) // 시작 시간으로 이동
      }

//      // 특정 시간 범위까지 재생 후 일시 정지하려면
//      player?.addBoundaryTimeObserver(forTimes: [NSValue(time: endTime)], queue: .main) {
//        [weak self] in
//        self?.stopAudio()
//      }
      DispatchQueue.main.async {
        self.isPlaying.toggle()
      }

      NotificationCenter.default.addObserver(
        self,
        selector: #selector(playerDidFinishPlaying(note:)),
        name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
        object: player?.currentItem)
    }
  }

  func pauseAudio() {
    player?.pause()
    timer?.invalidate()
    DispatchQueue.main.async {
      self.isPlaying = false
    }
  }

  func stopAudio() {
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
}
