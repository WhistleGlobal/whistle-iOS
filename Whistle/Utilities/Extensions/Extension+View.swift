//
//  Extension+View.swift
//  Whistle
//
//  Created by ChoiYujin on 8/29/23.
//

import Combine
import SwiftUI

// MARK: - font 관련 코드

extension View {
  func fontSystem(fontDesignSystem: FontSystem.FontDesignSystem) -> some View {
    modifier(FontSystem(fontDesignSystem: fontDesignSystem))
  }
}

// MARK: - GlassMorphism 관련 코드

extension View {
  @ViewBuilder
  func glassMorphicCard(width: CGFloat, height: CGFloat) -> some View {
    ZStack {
      CustomBlurView(effect: .systemUltraThinMaterialLight) { view in
        // FIXME: - 피그마와 비슷하도록 값 고치기
        view.gaussianBlurRadius = 30
      }
      .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
    .frame(width: width, height: height)
  }

  @ViewBuilder
  func glassMorphicTab() -> some View {
    ZStack {
      CustomBlurView(effect: .systemUltraThinMaterial) { view in
        // FIXME: - 피그마와 비슷하도록 값 고치기
        view.gaussianBlurRadius = 30
      }
      .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
    .frame(height: 56)
    .frame(maxWidth: .infinity)
  }
}

extension View {
  func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
    clipShape(RoundedCorners(radius: radius, corners: corners))
  }
}

// MARK: - 스크롤 모니터링 관련 코드

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
