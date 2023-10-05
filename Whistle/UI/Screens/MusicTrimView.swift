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

  @StateObject var apiViewModel = APIViewModel()
  @ObservedObject var musicVM: MusicViewModel
  @ObservedObject var editorVM: EditorViewModel
  @ObservedObject var videoPlayer: VideoPlayerManager

  @Binding var isShowingMusicTrimView: Bool
  @State private var audioURL: URL?
  @State private var startTime: TimeInterval = 0
  @State private var endTime: TimeInterval = 0
//  @State private var audioTrimRange: TimeInterval = 15
//  @State private var isTrimming = false
  @State private var isPlaying = false
  @State private var trimmedAudioURL: URL?
  @State private var player: AVPlayer?
  @State var offset: CGFloat = 0
  @State var isAnimated = false
  @State var isScrolling = false
  @State var audioTime: Double = 15
  @State var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
  @State var draggedOffset: Double = 0
  @State var accumulatedOffset: Double = 0
  @State var length: Double = 80

  // MARK: Internal

  var body: some View {
    ZStack {
      Color.black
        .ignoresSafeArea()
      ZStack(alignment: .center) {
        VStack {
          EditablePlayerView(player: videoPlayer.videoPlayer)
            .frame(height: UIScreen.getHeight(700))
          Spacer()
        }
        VStack(spacing: 0) {
          HStack {
            Button {
              Task {
                if let video = editorVM.currentVideo {
                  videoPlayer.action(video)
                  videoPlayer.scrubState = .scrubEnded(video.rangeDuration.lowerBound)
                }
                isShowingMusicTrimView = false
              }
            } label: {
              Text("취소")
                .fontSystem(fontDesignSystem: .subtitle2_KO)
                .foregroundStyle(Color.white)
            }
            Spacer()
            Button {} label: {
              Text("완료")
                .fontSystem(fontDesignSystem: .subtitle2_KO)
                .foregroundStyle(Color.Info)
            }
          }
          .padding(.horizontal, 16)
          .overlay {
            Text("음악 편집")
              .fontSystem(fontDesignSystem: .subtitle1_KO)
              .foregroundStyle(Color.white)
          }
          .frame(height: UIScreen.getHeight(44))
          Spacer()
          Text("드래그하여 영상에 추가할 부분을 선택하세요.")
            .fontSystem(fontDesignSystem: .body2_KO)
            .foregroundColor(.white)
            .padding(.bottom, UIScreen.getHeight(32))

          // MARK: - Audio Timeline Minimap

          ZStack(alignment: .leading) {
            // MARK: - Timeline minimap

            RoundedRectangle(cornerRadius: 20)
              .fill(.white)
              .frame(width: UIScreen.getWidth(273), height: UIScreen.getHeight(2))

            // MARK: - currentTime Indicator

            RoundedRectangle(cornerRadius: 6)
              .fill(Color.Secondary_Default)
              .frame(
                width: UIScreen.getWidth(CGFloat(273 / length * musicVM.trimmedDuration)),
                height: UIScreen.getHeight(8)
              )
              .offset(x: Double(288 * offset) / (Double(length) * 16.9) + draggedOffset)
              .gesture(
                DragGesture()
                  .onChanged { value in
                    draggedOffset = accumulatedOffset + value.translation.width
                  }
                  .onEnded { value in
                    accumulatedOffset += value.translation.width
                  })
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
                  .frame(width: isAnimated ? max(0.1, UIScreen.getWidth(175 - (audioTime / musicVM.trimmedDuration) * 175)) : 0)
              }

            // MARK: - Audio Waveform

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
                .padding(.horizontal, UIScreen.width / 2 - UIScreen.getWidth(175) / 2 + UIScreen.getWidth(12))
                .background(GeometryReader {
                  Color.clear.preference(key: ViewOffsetKey.self, value: -$0.frame(in: .named("scroll")).origin.x)
                })
                .onPreferenceChange(ViewOffsetKey.self) { offset in
                  self.offset = offset
                  // 각 note가 박스를 나갈 때마다 햅틱을 재생합니다. 0~1.7인 이유는 스크롤 시 뛰어넘는 offset이 가끔 발생하기 때문입니다.
                  if
                    (offset - 12).truncatingRemainder(dividingBy: 16.9) >= 0,
                    (offset - 12).truncatingRemainder(dividingBy: 16.9) <= 1.7
                  {
                    HapticManager.instance.impact(style: .soft)
                  }
                }
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
            if !isScrolling {
              Color.clear
//                .onAppear {
//                  timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
//                  isAnimated = true
//                  Task {
//                    await musicVM.playAudio(startTime: offset / 16.4, endTime: offset / 16.4 + musicVM.trimmedDuration)
//                  }
//                }
            } else {
              Color.clear
                .onAppear {
//                  if let duration = editorVM.currentVideo?.rangeDuration {
//                    videoPlayer.scrubState = .scrubEnded(duration.lowerBound)
//                  }
//                  timer.upstream.connect().cancel()
//                  audioTime = musicVM.trimmedDuration
//                  isAnimated = false
//                  musicVM.stopAudio()
                }
            }
          }
          .frame(height: UIScreen.getHeight(84))
        }
        .padding(.bottom, UIScreen.getHeight(130))
      }
      .onAppear {
        loadAudioFile()
        audioTime = musicVM.trimmedDuration
        if let url = musicVM.url {
          length = audioDuration(url)
        }
        timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
        isAnimated = true
        print("onAppear, 프로그레스바 시작 \(getTime())")
        if let video = editorVM.currentVideo {
          print("onAppear, 비디오 시작 \(getTime())")
          videoPlayer.action(video)
        }
        musicVM.playAudio(startTime: offset / 16.4, endTime: offset / 16.4 + musicVM.trimmedDuration)
        print("onAppear, 음악 시작 \(getTime())")
      }
      .onChange(of: videoPlayer.isPlaying) { value in
        if value == false, !isScrolling {
          if let video = editorVM.currentVideo {
            videoPlayer.action(video)
          }
        }
      }
      .onChange(of: isScrolling) { value in
        if let video = editorVM.currentVideo {
          print("스크롤 시작, 비디오 정지 및 시작 \(getTime())")
          videoPlayer.action(video)
        }
        switch value {
          case true:
            if let duration = editorVM.currentVideo?.rangeDuration {
              videoPlayer.scrubState = .scrubEnded(duration.lowerBound)
            }
            timer.upstream.connect().cancel()
            audioTime = musicVM.trimmedDuration
            print("scroll audioTime set \(getTime())")
            isAnimated = false
            musicVM.stopAudio()
          case false:
            timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
            isAnimated = true
              musicVM.playAudio(startTime: offset / 16.4, endTime: offset / 16.4 + musicVM.trimmedDuration)
              print("스크롤 시작, 음악 재설정 및 플레이 \(getTime())")
        }
      }
      .onReceive(timer) { _ in
        if audioTime == 0 {
          audioTime = musicVM.trimmedDuration
          print("타이머 종료, 재설정 \(getTime())")
          //                  timer.upstream.connect().cancel()
        } else {
          withAnimation(.linear(duration: 0.1)) {
            audioTime = max(0, audioTime - 0.1)
          }
        }
      }
      .onDisappear {
        musicVM.stopAudio()
        if videoPlayer.isPlaying {
          if let video = editorVM.currentVideo {
            videoPlayer.action(video)
          }
        }
      }
    }
  }
}

func getTime() -> String {
  let d = Date()
  let df = DateFormatter()
  df.dateFormat = "y-MM-dd H:mm:ss.SSSS"

  return df.string(from: d)
}

extension MusicTrimView {
  func loadAudioFile() {
    if let audioFileURL = musicVM.url {
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
//        isTrimming = false
        trimmedAudioURL = outputPath
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
        .frame(width: UIScreen.getWidth(6), height: abs(value))
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
