//
//  Extension+View.swift
//  Whistle
//
//  Created by ChoiYujin on 8/29/23.
//

import Combine
import Kingfisher
import SwiftUI

// MARK: - font 관련 코드

extension View {
  func fontSystem(fontDesignSystem: FontSystem.FontDesignSystem) -> some View {
    modifier(FontSystem(fontDesignSystem: fontDesignSystem))
  }
}

// MARK: - 추후 Sticky header
extension View {
  @ViewBuilder
  func offset(coordinateSpace: CoordinateSpace, completion: @escaping (CGFloat) -> ()) -> some View {
    overlay {
      GeometryReader { proxy in
        let minY = proxy.frame(in: coordinateSpace).minY
        Color.clear
          .preference(key: OffsetKey.self, value: minY)
          .onPreferenceChange(OffsetKey.self) { value in
            completion(value)
          }
      }
    }
  }
}

extension View {
  @ViewBuilder
  func profileImageView(url: String?, size: CGFloat) -> some View {
    if let url {
      KFImage.url(URL(string: url))
        .placeholder { // 플레이스 홀더 설정
          Image("ProfileDefault")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
        }
        .resizable()
        .scaledToFill()
        .frame(width: size, height: size)
        .clipShape(Circle())
    } else {
      Image("ProfileDefault")
        .resizable()
        .scaledToFit()
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
  }
}

// MARK: - GlassMorphism 관련 코드

extension View {

  @ViewBuilder
  func glassMorphicTab() -> some View {
    ZStack {
      RoundedRectangle(cornerRadius: 32, style: .continuous)
        .fill(Color.black.opacity(0.3))
      CustomBlurView(effect: .systemUltraThinMaterial) { view in
        view.saturationAmout = 2.2
        view.gaussianBlurRadius = 36
      }
      .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
    .frame(height: 56)
    .frame(maxWidth: .infinity)
  }

  @ViewBuilder
  func glassMoriphicView(width: CGFloat, height: CGFloat, cornerRadius: CGFloat) -> some View {
    ZStack {
      RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        .fill(Color.black.opacity(0.3))
      CustomBlurView(effect: .systemUltraThinMaterialLight) { view in
        // FIXME: - 피그마와 비슷하도록 값 고치기
        view.saturationAmout = 2.2
        view.gaussianBlurRadius = 36
      }
      .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
    .frame(width: width, height: height)
  }

  @ViewBuilder
  func glassProfile(width: CGFloat, height: CGFloat, cornerRadius: CGFloat, overlayed: some View) -> some View {
    glassMoriphicView(width: width, height: height, cornerRadius: cornerRadius)
      .overlay {
        RoundedRectangle(cornerRadius: cornerRadius)
          .stroke(lineWidth: 1)
          .foregroundStyle(
            LinearGradient.Border_Glass)
        overlayed
      }
  }

  // min max version
  @ViewBuilder
  func glassMoriphicView(width: CGFloat, minHeight: CGFloat, maxHeight: CGFloat, cornerRadius: CGFloat) -> some View {
    ZStack {
      RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        .fill(Color.black.opacity(0.3))
      CustomBlurView(effect: .systemUltraThinMaterialLight) { view in
        // FIXME: - 피그마와 비슷하도록 값 고치기
        view.saturationAmout = 2.2
        view.gaussianBlurRadius = 36
      }
      .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
    .frame(width: width)
    .frame(minHeight: minHeight, maxHeight: maxHeight)
  }

  @ViewBuilder
  func glassProfile(
    width: CGFloat,
    minHeight: CGFloat,
    maxHeight: CGFloat,
    cornerRadius: CGFloat,
    overlayed: some View)
    -> some View
  {
    glassMoriphicView(width: width, minHeight: minHeight, maxHeight: maxHeight, cornerRadius: cornerRadius)
      .overlay {
        RoundedRectangle(cornerRadius: cornerRadius)
          .stroke(lineWidth: 1)
          .foregroundStyle(
            LinearGradient.Border_Glass)
        overlayed
      }
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

extension View {
  func blurredSheet(
    _ style: AnyShapeStyle,
    show: Binding<Bool>,
    onDismiss: @escaping () -> Void,
    @ViewBuilder content: @escaping () -> some View)
    -> some View
  {
    sheet(isPresented: show, onDismiss: onDismiss) {
      content()
        .background(Removebackgroundcolor())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
          Rectangle()
            .fill(style)
            .ignoresSafeArea(.container, edges: .all)
        }
    }
  }
}

// MARK: - Removebackgroundcolor

fileprivate struct Removebackgroundcolor: UIViewRepresentable {
  func makeUIView(context _: Context) -> UIView {
    UIView()
  }

  func updateUIView(_ uiView: UIViewType, context _: Context) {
    DispatchQueue.main.async {
      uiView.superview?.superview?.backgroundColor = .clear
    }
  }
}
