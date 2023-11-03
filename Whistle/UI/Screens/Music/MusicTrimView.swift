//
//  MusicTrimView.swift
//  Whistle
//
//  Created by 박상원 on 2023/08/31.
//

import AVFoundation
import AVKit
import Combine
import SwiftUI

// MARK: - MusicTrimView

struct MusicTrimView: View {
  // MARK: Private

  @Environment(\.dismiss) private var dismiss

  @StateObject var apiViewModel = APIViewModel.shared
  @ObservedObject var musicVM: MusicViewModel
  @ObservedObject var editorVM: VideoEditorViewModel
  @ObservedObject var videoPlayer: VideoPlayerManager

  @State private var audioURL: URL?
  @State private var trimmedAudioURL: URL?
  @State private var player: AVPlayer?
  @State private var isPlaying = false
  @State private var startTime: TimeInterval = 0
  @State private var endTime: TimeInterval = 0

  @State var offset: CGFloat = 0
  @State var isAnimated = false
  @State var isScrolling = false
  @State var audioTimer: Double = 15
  @State var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
  @State var draggedOffset: Double = 0
  @State var accumulatedOffset: Double = 0
  @State var musicDuration: Double = 80
  @State var indicatorOffset: Double = 0
  @Binding var showMusicTrimView: Bool

  // MARK: Internal

  var body: some View {
    ZStack {
      Color.black
        .ignoresSafeArea()
      ZStack(alignment: .center) {
        VStack {
          EditablePlayer(player: videoPlayer.videoPlayer)
            .frame(height: UIScreen.getHeight(700))
            .overlay {
              VStack {
                LinearGradient(
                  colors: [.Gray50_Dark.opacity(0.8), .Gray50_Dark.opacity(0)],
                  startPoint: .top,
                  endPoint: .bottom)
                  .frame(height: UIScreen.getHeight(150))
                Spacer()
                LinearGradient(
                  colors: [.Gray50_Dark.opacity(0), .Gray50_Dark.opacity(0.36)],
                  startPoint: .top,
                  endPoint: .bottom)
                  .frame(height: UIScreen.getHeight(350))
              }
            }
          Spacer()
        }
        VStack(spacing: 0) {
          customNavigationBar()
          Spacer()

          // MARK: - Audio Timeline Minimap

          ZStack(alignment: .leading) {
            // MARK: - Timeline minimap

            RoundedRectangle(cornerRadius: 20)
              .fill(.white)
              .frame(width: UIScreen.getWidth(273), height: UIScreen.getHeight(2))

            // MARK: - currentTime Indicator

            RoundedRectangle(cornerRadius: 6)
              .fill(Color.Secondary_Default_Dark)
              .frame(
                width: UIScreen.getWidth(max(CGFloat(273 / musicDuration * musicVM.trimDuration), 12)),
                height: UIScreen.getHeight(8))
              .offset(x: UIScreen.getWidth(indicatorOffset))
//              .gesture(
//                DragGesture()
//                  .onChanged { value in
//                    draggedOffset = accumulatedOffset + value.translation.width
//                  }
//                  .onEnded { value in
//                    accumulatedOffset += value.translation.width
//                  })
          }
          .padding(.bottom, UIScreen.getHeight(40))

          // MARK: - Audio Timeline

          ZStack(alignment: .center) {
            // MARK: - Audio Play ProgressBox

            RoundedRectangle(cornerRadius: 8)
              .fill(LinearGradient.primaryGradient)
              .frame(width: UIScreen.getWidth(175), height: UIScreen.getHeight(84))
              .mask(alignment: .leading) {
                Rectangle()
                  .frame(
                    width: isAnimated
                      ? max(
                        0.1,
                        UIScreen.getWidth(175 - (audioTimer / musicVM.trimDuration) * 175))
                      : 0)
              }

            // MARK: - Audio Waveform

            waveform()
          }
          .frame(height: UIScreen.getHeight(84))
        }
        .padding(.bottom, UIScreen.getHeight(130))
        VStack {
          Spacer()
          Text("드래그하여 영상에 추가할 부분을 선택하세요.")
            .fontSystem(fontDesignSystem: .body2)
            .foregroundColor(.white)
            .padding(.bottom, UIScreen.getHeight(32))
        }
      }
      .onAppear {
        initialStart()
      }
      // 가만히 있는 상태에서 비디오가 멈췄을 때
      .onChange(of: videoPlayer.isPlaying) { value in
        if !value, !isScrolling {
          if let video = editorVM.currentVideo {
            videoPlayer.action(video)
          }
          audioTimer = musicVM.trimDuration
          musicVM.stopAudio()
        }
        if value {
          musicVM.playAudio(startTime: (offset / 16.0) * (musicVM.trimDuration / 10))
        }
      }
      // 스크롤중 / 스크롤 끝
      .onChange(of: isScrolling) { value in
        switch value {
        case true:
          stopPlaying()
        case false:
          startPlaying()
        }
      }
      .onReceive(timer) { _ in
        withAnimation(.linear(duration: 0.1)) {
          audioTimer = max(0, audioTimer - 0.1)
        }
      }
      .onDisappear {
        stopPlaying()
      }
    }
  }
}

extension MusicTrimView {
  @ViewBuilder
  func customNavigationBar() -> some View {
    HStack {
      Button {
        Task {
          stopPlaying()
          showMusicTrimView = false
          if !musicVM.isTrimmed {
            musicVM.musicInfo = nil
          }
        }
      } label: {
        Text(CommonWords().cancel)
          .fontSystem(fontDesignSystem: .subtitle2)
          .foregroundStyle(Color.white)
      }
      Spacer()
      Button {
        musicVM.startTime = (offset / 16.0) * (musicVM.trimDuration / 10)
        Task {
          stopPlaying()
          trimAudio()
          if !videoPlayer.isPlaying {
            showMusicTrimView = false
          }
        }
        musicVM.isTrimmed = true
      } label: {
        Text(CommonWords().done)
          .fontSystem(fontDesignSystem: .subtitle2)
          .foregroundStyle(Color.Info)
      }
    }
    .padding(.horizontal, 16)
    .overlay {
      Text(VideoEditorWords().trimMusic)
        .fontSystem(fontDesignSystem: .subtitle1)
        .foregroundStyle(Color.white)
    }
    .frame(height: UIScreen.getHeight(44))
  }

  @ViewBuilder
  func waveform() -> some View {
    ScrollViewReader { _ in
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 0) {
          if musicVM.soundSamples.isEmpty {
            ProgressView()
          } else {
            ForEach(musicVM.soundSamples, id: \.self) { model in
              BarView(value: normalizeSoundLevel(level: model.magnitude))
                .id(model.index)
            }
          }
        }
        .padding(.horizontal, UIScreen.width / 2 - UIScreen.getWidth(175) / 2)
        .padding(.leading, UIScreen.getWidth(12))
        .background(GeometryReader {
          Color.clear.preference(key: ViewOffsetKey.self, value: -$0.frame(in: .named("scroll")).origin.x)
        })
        .onPreferenceChange(ViewOffsetKey.self) { offset in
          self.offset = offset
          let currentTime = (offset / 16.0) * (musicVM.trimDuration / 10)
          let indicatorMaxOffset = 273 - max(CGFloat(273 / musicDuration * musicVM.trimDuration), 12)
          indicatorOffset = min(indicatorMaxOffset, 273 / musicDuration * currentTime)
          // 각 note가 박스를 나갈 때마다 햅틱을 재생합니다. 0~1.7인 이유는 스크롤 시 뛰어넘는 offset이 가끔 발생하기 때문입니다.
          if
            (offset - 12).truncatingRemainder(dividingBy: 16.9) >= 0,
            (offset - 12).truncatingRemainder(dividingBy: 16.9) <= 1.7
          {
            HapticManager.instance.impact(style: .soft)
          }
        }
        // 미니맵 드래그 함수
//                .onChange(of: draggedOffset) { _ in
//                  scrollProxy.scrollTo(10 - 7, anchor: .leading)
//                  isScrolling = true
//                  Task {
//                    isScrolling = false
//                  }
//                }
//                .onTapGesture {
//                  scrollProxy.scrollTo(50, anchor: .center)
//                  isScrolling = true
//                  Task {
//                    isScrolling = false
//                  }
//                }
      }
      .scrollStatusMonitor($isScrolling, monitorMode: .exclusion)
      .overlay {
        // MARK: - Audio Play ProgressBox Stoke

        RoundedRectangle(cornerRadius: 8)
          .strokeBorder(LinearGradient.primaryGradient, lineWidth: UIScreen.getWidth(6))
          .frame(width: UIScreen.getWidth(175), height: UIScreen.getHeight(84))
      }
    }
  }
}

extension MusicTrimView {
  func initialStart() {
//    musicVM.startTime = nil
    loadAudioFile()
//    print("starTtime:", musicVM.startTime)
//    if let starttime = musicVM.startTime {
//      offset = starttime * 16 * 10 / musicVM.trimDuration
//    } else {
    offset = 0
//    }
    if let url = musicVM.originalAudioURL {
      musicDuration = audioDuration(url)
    }
    startPlaying()
  }

  func startPlaying() {
    // progress 시작
    audioTimer = musicVM.trimDuration
    timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    isAnimated = true

    // 비디오 시작
    if let video = editorVM.currentVideo {
      videoPlayer.action(video)
    }
  }

  func stopPlaying() {
    // progress 정지
    audioTimer = musicVM.trimDuration
    timer.upstream.connect().cancel()
    isAnimated = false

    // 비디오 정지
    if let video = editorVM.currentVideo {
      videoPlayer.action(video)
    }
    if let duration = editorVM.currentVideo?.rangeDuration {
      videoPlayer.scrubState = .scrubEnded(duration.lowerBound)
    }

    // 음악 정지
    musicVM.stopAudio()
  }
}

extension MusicTrimView {
  func loadAudioFile() {
    if let audioFileURL = musicVM.originalAudioURL {
      audioURL = audioFileURL
      endTime = audioDuration(audioFileURL)
    }
  }

  /// 오디오의 전체 재생시간을 계산하는 함수입니다.
  /// - Parameter url: audio url
  /// - Returns: audio duration
  func audioDuration(_ url: URL) -> TimeInterval {
    let asset = AVURLAsset(url: url)
    return TimeInterval(asset.duration.seconds)
  }

  func trimAudio() {
    guard let audioURL else {
      return
    }

    let asset = AVURLAsset(url: audioURL)
    let startTime = CMTime(seconds: musicVM.startTime!, preferredTimescale: 1000)
    let endTime = CMTime(seconds: musicVM.startTime! + musicVM.trimDuration, preferredTimescale: 1000)
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
        trimmedAudioURL = outputPath
        musicVM.originalAudioURL = trimmedAudioURL
        editorVM.setAudio(Audio(url: trimmedAudioURL!, duration: musicVM.trimDuration))
      }
    })
  }

  func playTrimmedAudio() {
    guard let trimmedAudioURL else {
      return
    }
    if isPlaying {
      player?.pause()
    } else {
      let playerItem = AVPlayerItem(url: trimmedAudioURL)
      player = AVPlayer(playerItem: playerItem)
      player?.play()
    }

    isPlaying.toggle()
  }

  private func normalizeSoundLevel(level: Float) -> CGFloat {
    // 입력값을 원하는 범위 (-10에서 -30)로 정규화합니다.
    let normalizedValue = (level - -70) / (0 - -70)

    // 정규화된 값에 지수 함수를 적용하여 더 강조합니다.
    let adjustedValue = pow(10, normalizedValue)

    // 최종 결과값을 원하는 범위 (0.1 ~ 35)로 조정합니다.
    let adjustedResult = 0.1 + (adjustedValue - 1) / (pow(10, 1) - 1) * (35 - 0.1)
    return CGFloat(adjustedResult)
  }
}

// MARK: - ViewOffsetKey

struct ViewOffsetKey: PreferenceKey {
  typealias Value = CGFloat
  static var defaultValue = CGFloat.zero
  static func reduce(value: inout Value, nextValue: () -> Value) {
    value += nextValue()
  }
}

// MARK: - BarView

struct BarView: View {
  let value: CGFloat

  var body: some View {
    ZStack {
      Rectangle()
        .fill(Color.white)
        .cornerRadius(15)
        .frame(width: UIScreen.getWidth(6), height: UIScreen.getHeight(abs(value * 2.7) >= 84 ? 84 : abs(value * 2.7)))
        .padding(.trailing, UIScreen.getWidth(10))
    }
//    .frame(height: UIScreen.height * 0.1)
  }
}

// MARK: - MusicTrimView_Previews

// struct MusicTrimView_Previews: PreviewProvider {
//  static var previews: some View {
//    MusicTrimView(audio: "newjeans.mp3")
//  }
// }
