//
//  VideoPlayerManager.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import AVKit
import Combine
import Foundation
import PhotosUI
import SwiftUI

// MARK: - VideoPlayerManager

final class VideoPlayerManager: ObservableObject {
  @Published var currentTime: Double = .zero
  @Published var selectedItem: PhotosPickerItem?
  @Published var loadState: LoadState = .unknown
  @Published private(set) var videoPlayer = AVPlayer()
  @Published private(set) var audioPlayer = AVPlayer()
  @Published private(set) var isPlaying = false
  private var isSetAudio = false
  private var cancellable = Set<AnyCancellable>()
  private var timeObserver: Any?
  private var currentDurationRange: ClosedRange<Double>?

  func reset() {
//    currentTime = .zero
    selectedItem = nil
    videoPlayer = AVPlayer(playerItem: nil)
    loadState = .unknown
    isPlaying = false
    isSetAudio = false
    timeObserver = nil
    currentDurationRange = nil
    removeTimeObserver()
  }

  deinit {
    removeTimeObserver()
  }

  init() {
    onSubsURL()
  }

  var scrubState: PlayerScrubState = .reset {
    didSet {
      switch scrubState {
      case .scrubEnded(let seekTime):
        pause()
        seek(seekTime, player: videoPlayer)
        // 추가적인 오디오를 설정했다면 오디오 seek도 같이
        if isSetAudio {
          seek(seekTime, player: audioPlayer)
        }
      default: break
      }
    }
  }

  func action(_ video: EditableVideo) {
    currentDurationRange = video.rangeDuration
    if isPlaying {
      pause()
    } else {
      play(video.rate)
    }
  }

  func setAudio(_ url: URL?) {
    guard let url else {
      isSetAudio = false
      return
    }
    audioPlayer = .init(url: url)
    isSetAudio = true
  }

  func playLoop(_ video: EditableVideo) {
    NotificationCenter.default
      .addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { [weak self] _ in
        self?.action(video)
      }

    action(video)
  }

  private func onSubsURL() {
    $loadState
      .dropFirst()
      .receive(on: DispatchQueue.main)

      .sink { [weak self] returnLoadState in
        guard let self else { return }

        switch returnLoadState {
        case .loaded(let url):
          pause()
          videoPlayer = AVPlayer(url: url)
          startStatusSubscriptions()
        case .failed, .loading, .unknown:
          break
        }
      }
      .store(in: &cancellable)
  }

  private func startStatusSubscriptions() {
    videoPlayer.publisher(for: \.timeControlStatus)
      .sink { [weak self] status in
        guard let self else { return }
        switch status {
        case .playing:
          isPlaying = true
          startTimer()
        case .paused:
          isPlaying = false
        case .waitingToPlayAtSpecifiedRate:
          break
        @unknown default:
          break
        }
      }
      .store(in: &cancellable)
  }

  func pause() {
    if isPlaying {
      videoPlayer.pause()
      if isSetAudio {
        audioPlayer.pause()
      }
    }
  }

  func setVolume(_ isVideo: Bool, value: Float) {
    pause()
    if isVideo {
      videoPlayer.volume = value
    } else {
      audioPlayer.volume = value
    }
  }

  private func play(_ rate: Float?) {
    AVAudioSession.sharedInstance().configurePlaybackSession()

    if let currentDurationRange {
      if currentTime >= currentDurationRange.upperBound {
        seek(currentDurationRange.lowerBound, player: videoPlayer)
        if isSetAudio {
          seek(currentDurationRange.lowerBound, player: audioPlayer)
        }
      } else {
        seek(videoPlayer.currentTime().seconds, player: videoPlayer)
        if isSetAudio {
          seek(audioPlayer.currentTime().seconds, player: audioPlayer)
        }
      }
    }

    videoPlayer.play()
    if isSetAudio {
      audioPlayer.play()
    }

    if let rate {
      videoPlayer.rate = rate
      if isSetAudio {
        audioPlayer.play()
      }
    }

    if let currentDurationRange, videoPlayer.currentItem?.duration.seconds ?? 0 >= currentDurationRange.upperBound {
      NotificationCenter.default.addObserver(
        forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
        object: videoPlayer.currentItem,
        queue: .main)
      { _ in
        self.playerDidFinishPlaying()
      }
    }
  }

  private func seek(_ seconds: Double, player: AVPlayer) {
    player.seek(to: CMTime(seconds: seconds, preferredTimescale: 600))
  }

  private func startTimer() {
    let interval = CMTimeMake(value: 1, timescale: 10)
    timeObserver = videoPlayer.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
      guard let self else { return }
      if isPlaying {
        let time = time.seconds

        if let currentDurationRange, time >= currentDurationRange.upperBound {
          pause()
        }

        switch scrubState {
        case .reset:
          currentTime = time
        case .scrubEnded:
          scrubState = .reset
        case .scrubStarted:
          break
        }
      }
    }
  }

  private func playerDidFinishPlaying() {
//    videoPlayer.seek(to: .zero)
    if let currentDurationRange {
      seek(currentDurationRange.lowerBound, player: videoPlayer)
    }
  }

  private func removeTimeObserver() {
    if let timeObserver {
      videoPlayer.removeTimeObserver(timeObserver)
    }
  }
}

extension VideoPlayerManager {
  @MainActor
  func loadVideoItem(_ selectedItem: PhotosPickerItem?) async {
    do {
      loadState = .loading

      if let video = try await selectedItem?.loadTransferable(type: VideoItem.self) {
        loadState = .loaded(video.url)
      } else {
        loadState = .failed
      }
    } catch {
      loadState = .failed
    }
  }
}

extension VideoPlayerManager {
  func setFilters(mainFilter: CIFilter?, colorCorrection: ColorCorrection?) {
    let filters = VideoFilterHelpers.createFilters(mainFilter: mainFilter, colorCorrection)

    if filters.isEmpty {
      return
    }
    pause()
    DispatchQueue.global(qos: .userInteractive).async {
      let composition = self.videoPlayer.currentItem?.asset.setFilters(filters)
      self.videoPlayer.currentItem?.videoComposition = composition
    }
  }

  func removeFilter() {
    pause()
    videoPlayer.currentItem?.videoComposition = nil
  }
}

// MARK: - LoadState

enum LoadState: Identifiable, Equatable {
  case unknown, loading, loaded(URL), failed

  var id: Int {
    switch self {
    case .unknown: 0
    case .loading: 1
    case .loaded: 2
    case .failed: 3
    }
  }
}

// MARK: - PlayerScrubState

enum PlayerScrubState {
  case reset
  case scrubStarted
  case scrubEnded(Double)
}

extension AVAsset {
  func setFilter(_ filter: CIFilter) -> AVVideoComposition {
    let composition = AVVideoComposition(asset: self, applyingCIFiltersWithHandler: { request in
      filter.setValue(request.sourceImage, forKey: kCIInputImageKey)

      guard let output = filter.outputImage else { return }

      request.finish(with: output, context: nil)
    })

    return composition
  }

  func setFilters(_ filters: [CIFilter]) -> AVVideoComposition {
    let composition = AVVideoComposition(asset: self, applyingCIFiltersWithHandler: { request in

      let source = request.sourceImage
      var output = source

      filters.forEach { filter in
        filter.setValue(output, forKey: kCIInputImageKey)
        if let image = filter.outputImage {
          output = image
        }
      }

      request.finish(with: output, context: nil)
    })

    return composition
  }
}
