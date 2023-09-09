//
//  AudioPlayerViewModel.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/05.
//

import AVFoundation
import AVKit
import Combine
import Foundation
import SwiftUI

class AudioPlayViewModel: ObservableObject {
  private var timer: Timer?

  @Published var isPlaying = false

  @Published public var soundSamples = [AudioPreviewModel]()
  let sample_count: Int
  var index = 0
  let url: URL

  var dataManager: ServiceProtocol

  @Published var player: AVPlayer?
  @Published var session: AVAudioSession!

  init(url _: URL, sampels_count: Int, dataManager: ServiceProtocol = Service.shared) {
    url = Bundle.main.url(forResource: "newjeans", withExtension: "mp3")!
    sample_count = sampels_count
    self.dataManager = dataManager

    visualizeAudio()

    do {
      session = AVAudioSession.sharedInstance()
      try session.setCategory(.playAndRecord)

      try session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)

    } catch {
      print(error.localizedDescription)
    }

    player = AVPlayer(url: url)
  }

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

  @objc
  func playerDidFinishPlaying(note _: NSNotification) {
    player?.pause()
    player?.seek(to: .zero)
    timer?.invalidate()
    isPlaying = false
    index = 0
    soundSamples = soundSamples.map { tmp -> AudioPreviewModel in
      var cur = tmp
      cur.color = Color.gray
      return cur
    }
  }

  func playAudio(startTime: Double, endTime: Double) {
    if isPlaying {
      pauseAudio()
    } else {
      player = AVPlayer(url: url)
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(playerDidFinishPlaying(note:)),
        name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
        object: player?.currentItem)
      let startTime = CMTime(seconds: startTime, preferredTimescale: 1)
      let endTime = CMTime(seconds: endTime, preferredTimescale: 1)
//      let endTime = CMTimeAdd(startTime, CMTime(seconds: 15, preferredTimescale: 1))

      print("startTime: \(startTime.seconds), endTime: \(endTime.seconds)")
      player?.seek(to: startTime) // 시작 시간으로 이동
      player?.play()

      startTimer()
      count_duration { _ in }

      // 특정 시간 범위까지 재생 후 일시 정지하려면
      player?.addBoundaryTimeObserver(forTimes: [NSValue(time: endTime)], queue: .main) {
        [weak self] in
//        self?.pauseAudio()
        self?.stopAudio()
      }

      isPlaying.toggle()
    }
  }

  func pauseAudio() {
    player?.pause()
    timer?.invalidate()
    isPlaying = false
  }

  func stopAudio() {
    player?.pause()
    timer?.invalidate()
    isPlaying = false
    player = nil
  }

  func count_duration(completion: @escaping (Float64) -> Void) {
    DispatchQueue.global(qos: .background).async {
      if let duration = self.player?.currentItem?.asset.duration {
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

  func visualizeAudio() {
    dataManager.buffer(url: url, samplesCount: sample_count) { results in
      self.soundSamples = results
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
