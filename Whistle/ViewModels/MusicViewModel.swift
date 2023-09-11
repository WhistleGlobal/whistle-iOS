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

class MusicViewModel: ObservableObject {
  private var timer: Timer?
  private var downloadedAudioURL: URL?

  @Published var isPlaying = false
  @Published public var soundSamples = [MusicNote]()
  /// 오디오를 샘플링하기 위한 count
  let sample_count: Int

  /// 샘플링된 정보를 배열에 저장할 때 필요한 index
  var index = 0
  /// 오디오 url
  let url: URL

  var dataManager: MusicServiceProtocol

  @Published var player: AVPlayer?
  @Published var session: AVAudioSession!

  init(url _: URL, samples_count: Int, dataManager: MusicServiceProtocol = MusicService.shared) {
    url = URL(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3")!
    sample_count = samples_count
    self.dataManager = dataManager
    print("init!!!")
    // 주어진 sample_count와 dataManager로 visualizing을 시작합니다.
    Task {
      await visualizeAudio()
    }

    // AudioSession의 카테고리를 playback으로 설정하고, 오디오 출력은 기존의 포트를 사용합니다.
    do {
      session = AVAudioSession.sharedInstance()
      try session.setCategory(.playback)

      try session.overrideOutputAudioPort(AVAudioSession.PortOverride.none)

    } catch {
      print(error.localizedDescription)
    }

//    player = AVPlayer(url: url)
    // 다운로드된 오디오 파일이 없을 때만 다운로드하도록 처리
    if
      let downloadedURL = try? FileManager.default.url(
        for: .documentDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true).appendingPathComponent("downloadedAudio.mp3")
    {
      if FileManager.default.fileExists(atPath: downloadedURL.path) {
        // 이미 다운로드된 파일이 있는 경우, 다운로드한 파일의 URL 저장
        downloadedAudioURL = downloadedURL
      } else {
        // 파일이 없는 경우 다운로드 진행
        Task {
          do {
            downloadedAudioURL = try await dataManager.downloadMusicAsync(from: url)
          } catch {
            print("Audio download error: \(error)")
          }
        }
      }
    }

    // 다운로드가 완료되지 않은 경우에도 기본 URL 사용
    if downloadedAudioURL == nil {
      downloadedAudioURL = url
    }

    player = AVPlayer(url: downloadedAudioURL!)
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
    let results = try? await dataManager.buffer(url: url, samplesCount: sample_count)
    DispatchQueue.main.async {
      self.soundSamples = results ?? []
    }
  }

  func playAudio(startTime: Double, endTime: Double) async {
    if isPlaying {
      pauseAudio()
    } else {
      DispatchQueue.main.async {
        self.player = AVPlayer(url: self.downloadedAudioURL!)
        print("url: \(self.downloadedAudioURL!)")
        self.player?.play()
      }

      NotificationCenter.default.addObserver(
        self,
        selector: #selector(playerDidFinishPlaying(note:)),
        name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
        object: player?.currentItem)
      let startTime = CMTime(seconds: startTime, preferredTimescale: 1)
      let endTime = CMTime(seconds: endTime, preferredTimescale: 1)
      await player?.seek(to: startTime) // 시작 시간으로 이동
      player?.play()
      print("playing: \(player?.currentItem?.currentTime().seconds)")
      startTimer()
      count_duration { _ in }

      // 특정 시간 범위까지 재생 후 일시 정지하려면
      player?.addBoundaryTimeObserver(forTimes: [NSValue(time: endTime)], queue: .main) {
        [weak self] in
//        self?.pauseAudio()
        self?.stopAudio()
      }
      DispatchQueue.main.async {
        self.isPlaying.toggle()
      }
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
      try FileManager.default.removeItem(at: url)
    } catch {
      print(error)
    }
  }
}
