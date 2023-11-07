//
//  InteractivePreview.swift
//
//
//  Created by Young Bin on 2023/06/30.
//

import AVFoundation
import Combine
import SwiftUI

// MARK: - InteractivePreviewOption

/// Struct that contains the options for customizing an `InteractivePreview`.
///
/// The options include enabling or disabling certain interactive features such as changing position,
/// zooming, focusing, adjusting focus mode when moved, and showing a crosshair.
public struct InteractivePreviewOption {
  /// Flag that controls whether the camera position can be changed. Default is `true`.
  public var enableChangePosition = true

  /// Flag that controls whether zoom functionality is enabled. Default is `true`.
  public var enableZoom = true

  /// Flag that controls whether focus can be manually adjusted. Default is `true`.
  public var enableFocus = true

  /// Flag that controls whether the focus mode is changed when the camera is moved. Default is `true`.
  public var enableChangeFocusModeWhenMoved = true

  /// Flag that controls whether a crosshair is displayed on the preview. Default is `true`.
  public var enableShowingCrosshair = true

  /// Initialize the option
  public init(
    enableChangePosition: Bool = true,
    enableZoom: Bool = true,
    enableFocus: Bool = true,
    enableChangeFocusModeWhenMoved: Bool = true,
    enableShowingCrosshair: Bool = true)
  {
    self.enableChangePosition = enableChangePosition
    self.enableZoom = enableZoom
    self.enableFocus = enableFocus
    self.enableChangeFocusModeWhenMoved = enableChangeFocusModeWhenMoved
    self.enableShowingCrosshair = enableShowingCrosshair
  }
}

// MARK: - InteractivePreview

public struct InteractivePreview: View {
  private let option: InteractivePreviewOption
  private let preview: Preview

  // Zoom
  @State private var previousZoomFactor: CGFloat = 1.0
  @State public var currentZoomFactor: CGFloat = 1.0

  // Foocus
  @State private var preferredFocusMode: AVCaptureDevice.FocusMode = .continuousAutoFocus
  @State private var focusingLocation = CGPoint.zero

  // Crosshair
  @State private var focusFrameOpacity: Double = 0
  @State private var showingCrosshairTask: Task<Void, Error>?

  private var subjectAreaChangeMonitoringSubscription: Cancellable?

  init(_ preview: Preview, option: InteractivePreviewOption = .init()) {
    self.preview = preview
    self.option = option
    preferredFocusMode = preview.session.currentFocusMode ?? .continuousAutoFocus

    subjectAreaChangeMonitoringSubscription = preview
      .session
      .getSubjectAreaDidChangePublisher()
      .sink(receiveValue: { [self] _ in
        if option.enableChangeFocusModeWhenMoved {
          resetFocusMode()
        }
      })
  }

  var session: AespaSession {
    preview.session
  }

  var layer: AVCaptureVideoPreviewLayer {
    preview.previewLayer
  }

  var currentFocusMode: AVCaptureDevice.FocusMode? {
    session.currentFocusMode
  }

  var currentCameraPosition: AVCaptureDevice.Position? {
    session.currentCameraPosition
  }

  public var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .top) {
        preview
          .gesture(changePositionGesture)
          .gesture(tapToFocusGesture(geometry)) // Currently disabled
          .gesture(pinchZoomGesture)
        // Crosshair
        Circle()
          .stroke(lineWidth: 1)
          .foregroundColor(Color.white)
          .frame(width: 60, height: 60)
          .shadow(radius: 10)
          .position(focusingLocation)
          .opacity(focusFrameOpacity)
          .animation(.spring(), value: focusFrameOpacity)
      }
    }
    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
//    .padding(.bottom, 68)
  }
}

extension InteractivePreview {
  private var changePositionGesture: some Gesture {
    guard session.isRunning, option.enableChangePosition else {
      return TapGesture(count: 2).onEnded { }
    }

    return TapGesture(count: 2).onEnded {
      let nextPosition: AVCaptureDevice.Position = (currentCameraPosition == .back) ? .front : .back
      session.position(to: nextPosition)
    }
  }

  private func tapToFocusGesture(_ geometry: GeometryProxy) -> some Gesture {
//    guard session.isRunning, option.enableFocus else {
    ////      return DragGesture(minimumDistance: 0).onEnded { _ in }
    ////      return TapGesture(count: 1).onEnded { }
//      return SpatialTapGesture(count: 1, coordinateSpace: .global).onEnded { _ in }
//    }

    DragGesture(minimumDistance: 0)
      .onEnded { value in
        guard
          let currentFocusMode,
          currentFocusMode == .locked || currentFocusMode == .continuousAutoFocus
        else {
          return
        }

        var point = value.location
        point = CGPoint(
          x: point.x / geometry.size.width,
          y: point.y / geometry.size.height)
        session.focus(mode: .autoFocus, point: point)
        focusingLocation = value.location

        if option.enableShowingCrosshair, point.y <= 1.0 {
          showCrosshair()
        }
      }
  }

  private var pinchZoomGesture: some Gesture {
    guard session.isRunning, option.enableZoom else {
      return MagnificationGesture().onChanged { _ in }.onEnded { _ in }
    }

    let maxZoomFactor = session.maxZoomFactor ?? 1.0
    return MagnificationGesture()
      .onChanged { scale in
        if scale * previousZoomFactor > 5.0 {
          return
        }
        let videoZoomFactor = scale * previousZoomFactor
        if videoZoomFactor <= 5.0 {
          let newZoomFactor = max(1.0, min(videoZoomFactor, 5.0))
          session.zoom(factor: newZoomFactor)
          ZoomFactorCombineViewModel.shared.zoomScale = newZoomFactor
        }
      }
      .onEnded { scale in
        let videoZoomFactor = max(1.0, min(scale * previousZoomFactor, 5.0))
        previousZoomFactor = videoZoomFactor >= 1 ? videoZoomFactor : 1
        ZoomFactorCombineViewModel.shared.zoomScale = previousZoomFactor
      }
  }

  public func resetZoom() {
    ZoomFactorCombineViewModel.shared.zoomScale = 1.0
    currentZoomFactor = 1.0
    previousZoomFactor = 1.0
    session.zoom(factor: 1.0)
  }


  private func resetFocusMode() {
    guard session.isRunning else { return }
    session.focus(mode: preferredFocusMode)
  }

  private func showCrosshair() {
    guard option.enableShowingCrosshair else { return }

    // Cancel the previous task
    showingCrosshairTask?.cancel()
    // Running a new task
    showingCrosshairTask = Task {
      // 10^9 nano seconds = 1 second
      let second: UInt64 = 1_000_000_000

      withAnimation { focusFrameOpacity = 1 }

//      try await Task.sleep(nanoseconds: 2 * second)
//      withAnimation { focusFrameOpacity = 0.35 }

      try await Task.sleep(nanoseconds: 1 * second)
      withAnimation { focusFrameOpacity = 0 }
    }
  }
}
