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

  @StateObject private var audioVM: AudioPlayViewModel
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

  init(audio: String) {
    let length = Int(AVURLAsset(url: Bundle.main.url(forResource: "newjeans", withExtension: "mp3")!).duration.seconds)
    self.length = length
    _audioVM = StateObject(wrappedValue: AudioPlayViewModel(url: URL(string: audio)!, sampels_count: length))
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
                if audioVM.soundSamples.isEmpty {
                  ProgressView()
                } else {
                  ForEach(audioVM.soundSamples, id: \.self) { model in
                    BarView(value: normalizeSoundLevel(level: model.magnitude), color: model.color)
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
                audioVM.playAudio(startTime: offset / 16.4, endTime: offset / 16.4 + 15)
              }
          } else {
            Color.clear
              .onAppear {
                timer.upstream.connect().cancel()
                audioTime = 15
                isAnimated = false
                audioVM.stopAudio()
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
  var color: Color = .white

  var body: some View {
    ZStack {
      Rectangle()
//        .fill(color)
        .fill(Color.white)
        .cornerRadius(15)
        .frame(width: UIScreen.getWidth(6), height: value * 2.5)
        .padding(.trailing, UIScreen.getWidth(10))
    }
    .frame(height: UIScreen.height * 0.1)
  }
}

// MARK: - MusicTrimView_Previews

struct MusicTrimView_Previews: PreviewProvider {
  static var previews: some View {
    MusicTrimView(audio: "newjeans.mp3")
  }
}

extension View {
  @ViewBuilder
  public func scrollStatusMonitor(_ isScrolling: Binding<Bool>, monitorMode: ScrollStatusMonitorMode) -> some View {
    switch monitorMode {
    case .common:
      modifier(ScrollStatusMonitorCommonModifier(isScrolling: isScrolling))
    #if !os(macOS) && !targetEnvironment(macCatalyst)
    case .exclusion:
      modifier(ScrollStatusMonitorExclusionModifier(isScrolling: isScrolling))
    #endif
    }
  }

  public func scrollSensor() -> some View {
    overlay(
      GeometryReader { proxy in
        Color.clear
          .preference(
            key: MinValueKey.self,
            value: proxy.frame(in: .global))
      })
  }
}

// MARK: - IsScrollingValueKey

struct IsScrollingValueKey: EnvironmentKey {
  static var defaultValue = false
}

extension EnvironmentValues {
  public var isScrolling: Bool {
    get { self[IsScrollingValueKey.self] }
    set { self[IsScrollingValueKey.self] = newValue }
  }
}

// MARK: - MinValueKey

public struct MinValueKey: PreferenceKey {
  public static var defaultValue: CGRect = .zero
  public static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
    value = nextValue()
  }
}

#if !os(macOS) && !targetEnvironment(macCatalyst)
struct ScrollStatusMonitorExclusionModifier: ViewModifier {
  @StateObject private var store = ExclusionStore()
  @Binding var isScrolling: Bool
  func body(content: Content) -> some View {
    content
      .environment(\.isScrolling, store.isScrolling)
      .onChange(of: store.isScrolling) { value in
        isScrolling = value
      }
      .onDisappear {
        store.cancellable = nil
      }
  }
}

final class ExclusionStore: ObservableObject {
  @Published var isScrolling = false

  private let idlePublisher = Timer.publish(every: 0.1, on: .main, in: .default).autoconnect()
  private let scrollingPublisher = Timer.publish(every: 0.1, on: .main, in: .tracking).autoconnect()

  private var publisher: some Publisher {
    scrollingPublisher
      .map { _ in 1 }
      .merge(
        with:
        idlePublisher
          .map { _ in 0 })
  }

  var cancellable: AnyCancellable?

  init() {
    cancellable = publisher
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { _ in }, receiveValue: { output in
        guard let value = output as? Int else { return }
        if value == 1,!self.isScrolling {
          self.isScrolling = true
        }
        if value == 0, self.isScrolling {
          self.isScrolling = false
        }
      })
  }
}
#endif

// MARK: - ScrollStatusMonitorCommonModifier

struct ScrollStatusMonitorCommonModifier: ViewModifier {
  @StateObject private var store = CommonStore()
  @Binding var isScrolling: Bool
  func body(content: Content) -> some View {
    content
      .environment(\.isScrolling, store.isScrolling)
      .onChange(of: store.isScrolling) { value in
        isScrolling = value
      }
      .onPreferenceChange(MinValueKey.self) { _ in
        store.preferencePublisher.send(1)
      }
      .onDisappear {
        store.cancellable = nil
      }
  }
}

// MARK: - CommonStore

final class CommonStore: ObservableObject {
  @Published var isScrolling = false
  private var timestamp = Date()

  let preferencePublisher = PassthroughSubject<Int, Never>()
  let timeoutPublisher = PassthroughSubject<Int, Never>()

  private var publisher: some Publisher {
    preferencePublisher
      .dropFirst(2)
      .handleEvents(
        receiveOutput: { _ in
          // Ensure that when multiple scrolling components are scrolling at the same time,
          // the stop state of each can still be obtained individually
          self.timestamp = Date()
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            if Date().timeIntervalSince(self.timestamp) > 0.1 {
              self.timeoutPublisher.send(0)
            }
          }
        })
      .merge(with: timeoutPublisher)
  }

  var cancellable: AnyCancellable?

  init() {
    cancellable = publisher
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { _ in }, receiveValue: { output in
        guard let value = output as? Int else { return }
        if value == 1,!self.isScrolling {
          self.isScrolling = true
        }
        if value == 0, self.isScrolling {
          self.isScrolling = false
        }
      })
  }
}

// MARK: - ScrollStatusMonitorMode

/// Monitoring mode for scroll status
public enum ScrollStatusMonitorMode {
  #if !os(macOS) && !targetEnvironment(macCatalyst)
  /// The judgment of the start and end of scrolling is more accurate and timely. ( iOS only )
  ///
  /// But only for scenarios where there is only one scrollable component in the screen
  case exclusion
  #endif
  /// This mode should be used when there are multiple scrollable parts in the scene.
  ///
  /// * The accuracy and timeliness are slightly inferior to the exclusion mode.
  /// * When using this mode, a **scroll sensor** must be added to the subview of the scroll widget.
  case common
}
