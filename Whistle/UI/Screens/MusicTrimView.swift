//
//  MusicTrimView.swift
//  Whistle
//
//  Created by 박상원 on 2023/08/31.
//

import AVFoundation
import Combine
import SwiftUI

// MARK: - MusicTrimView

struct MusicTrimView: View {
  // MARK: Private

  @StateObject var apiViewModel = APIViewModel()

  @StateObject private var musicVM: MusicViewModel
  @State private var audioURL: URL?
  @State private var startTime: TimeInterval = 0
  @State private var endTime: TimeInterval = 0
  @State private var audioTrimRange: TimeInterval = 15
  @State private var isTrimming = false
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
  var length = 1

  init(audio _: String) {
    let length = Int(AVURLAsset(url: Bundle.main.url(forResource: "newjeans", withExtension: "mp3")!).duration.seconds)
    self.length = length
    _musicVM = StateObject(wrappedValue: MusicViewModel(
      url: URL(string: "http://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Sevish_-__nbsp_.mp3")!,
      samples_count: length))
  }

  // MARK: Internal

  var body: some View {
    ZStack {
      Color.black
      VStack(alignment: .center, spacing: 0) {
        Image("testCat")
          .resizable()
          .scaledToFill()
          .frame(width: UIScreen.getWidth(203), height: UIScreen.getHeight(361))
          .padding(.bottom, UIScreen.getHeight(40))
        Text("영상에 추가할 부분을 선택하세요.")
          .fontSystem(fontDesignSystem: .body2_KO)
          .foregroundColor(.white)
          .padding(.bottom, UIScreen.getHeight(32))

        // MARK: - Audio Timeline Minimap

        ZStack(alignment: .leading) {
          RoundedRectangle(cornerRadius: 20)
            .fill(.white)
            .frame(width: UIScreen.getWidth(273), height: UIScreen.getHeight(2))
          RoundedRectangle(cornerRadius: 6)
            .fill(Color.Secondary_Default)
            .frame(width: UIScreen.getWidth(CGFloat(273 / length * 15)), height: UIScreen.getHeight(8))
            .offset(x: Double(288 * offset) / (Double(length) * 16.9) + draggedOffset)
            .gesture(
              DragGesture()
                .onChanged { value in
                  draggedOffset = accumulatedOffset + value.translation.width
                  print(draggedOffset)
                }
                .onEnded { value in
                  accumulatedOffset += value.translation.width
                })
        }
        .padding(.bottom, UIScreen.getHeight(40))
        .onAppear {
          print(apiViewModel.idToken)
          Task {
            print(await apiViewModel.requestMusicList())
          }
        }

        // MARK: - Audio Timeline

        ZStack(alignment: .center) {
          // MARK: - Audio Play ProgressBox

          RoundedRectangle(cornerRadius: 8)
            .fill(LinearGradient.primaryGradient)
            .frame(width: UIScreen.getWidth(175), height: UIScreen.getHeight(84))
            .mask(alignment: .leading) {
              Rectangle()
                .frame(width: isAnimated ? UIScreen.getWidth(175 - (audioTime / 15) * 175) : 0)
            }
            .onReceive(timer) { _ in
              if audioTime < 0.1 {
                timer.upstream.connect().cancel()
              } else {
                withAnimation(.linear(duration: 0.1)) {
                  audioTime -= 0.1
                }
              }
            }

          // MARK: - Audio Waveform

          ScrollViewReader { scrollProxy in
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
              .onChange(of: draggedOffset) { _ in
                scrollProxy.scrollTo(10 - 7, anchor: .leading)
                isScrolling = true
                Task {
                  isScrolling = false
                }
              }
              .onTapGesture {
                scrollProxy.scrollTo(50, anchor: .center)
                isScrolling = true
                Task {
                  isScrolling = false
                }
              }
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
              .onAppear {
                timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
                isAnimated = true
                Task {
                  await musicVM.playAudio(startTime: offset / 16.4, endTime: offset / 16.4 + 15)
                }
              }
          } else {
            Color.clear
              .onAppear {
                timer.upstream.connect().cancel()
                audioTime = 15
                isAnimated = false
                musicVM.stopAudio()
              }
          }
        }
        .frame(height: UIScreen.getHeight(84))
      }
      .onAppear {
        loadAudioFile()
      }
    }
    .ignoresSafeArea()
  }
}

extension MusicTrimView {
  func loadAudioFile() {
    if let audioFileURL = Bundle.main.url(forResource: "newjeans", withExtension: "mp3") {
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
        isTrimming = false
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

struct MusicTrimView_Previews: PreviewProvider {
  static var previews: some View {
    MusicTrimView(audio: "newjeans.mp3")
  }
}
