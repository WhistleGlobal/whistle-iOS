//
//  RangeSliderView.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import SwiftUI

// MARK: - RangedSliderView

struct RangedSliderView: View {
  @ObservedObject var editorVM: EditorViewModel
  @ObservedObject var videoPlayer: VideoPlayerManager
  @State var originalValue: ClosedRange<Double> = 0 ... 15
  let currentValue: Binding<ClosedRange<Double>>?
  let currentTime: Binding<Double>
  let sliderBounds: ClosedRange<Double>
  let step: Double
  let onEndChange: () -> Void
  let strokeWidth: CGFloat = 4

  init(
    editor: EditorViewModel,
    player: VideoPlayerManager,
    value: Binding<ClosedRange<Double>>?,
    currentTime: Binding<Double>,
    bounds: ClosedRange<Double>,
    step: Double = 1,
    onEndChange: @escaping () -> Void)
  {
    editorVM = editor
    videoPlayer = player
    self.onEndChange = onEndChange
    self.currentTime = currentTime
    self.step = step
    currentValue = value
    sliderBounds = bounds
  }

  var body: some View {
    GeometryReader { geomentry in
      sliderView(sliderSize: geomentry.size)
    }
  }

  @ViewBuilder
  private func sliderView(sliderSize: CGSize) -> some View {
    let sliderViewYCenter = sliderSize.height / 2
    ZStack(alignment: .leading) {
      let sliderBoundDifference = sliderBounds.upperBound / step
      // 1초당 화면에서 차지하는 width pixel
      let stepWidthInPixel = CGFloat(sliderSize.width) / CGFloat(sliderBoundDifference)

      // 최대 15초
      let maxDuration = stepWidthInPixel * 15

      // Calculate Left Thumb initial position
      // 왼쪽 한계에 닿았다면 0, 아니라면
      let leftThumbLocation: CGFloat = currentValue?.wrappedValue.lowerBound == sliderBounds.lowerBound
        ? 0
        : CGFloat((currentValue?.wrappedValue.lowerBound ?? 0) - sliderBounds.lowerBound) * stepWidthInPixel

      // Calculate right thumb initial position

      let rightThumbLocation = CGFloat(currentValue?.wrappedValue.upperBound ?? 1) * stepWidthInPixel
      let editedDurationPixel = rightThumbLocation - leftThumbLocation

      let leftThumbPoint = CGPoint(x: leftThumbLocation, y: sliderViewYCenter)
      let rightThumbPoint = CGPoint(x: rightThumbLocation, y: sliderViewYCenter)

      // Line Betwwen Handles
      lineBetweenThumbs(from: leftThumbLocation, width: editedDurationPixel)

      // Left Thumb Handle
      thumbView(height: sliderSize.height, position: leftThumbPoint, isLeftThumb: true)
        .highPriorityGesture(
          DragGesture().onChanged { dragValue in
            let dragLocation = dragValue.location
            let xThumbOffset = min(max(0, dragLocation.x), sliderSize.width)

            // newValue는 초로 계산.
            let newValue = (sliderBounds.lowerBound) + (xThumbOffset / stepWidthInPixel)

            // Stop the range thumbs from colliding each other
            // 비디오 duration 재지정.
            if newValue < currentValue?.wrappedValue.upperBound ?? 1 {
              if (currentValue?.wrappedValue.upperBound ?? 1) - newValue <= 15 {
                currentValue?.wrappedValue = newValue ... (currentValue?.wrappedValue.upperBound ?? 1)
              } else {
                currentValue?
                  .wrappedValue = (currentValue?.wrappedValue.upperBound ?? 15) - 15 ...
                  (currentValue?.wrappedValue.upperBound ?? 1)
              }
            }
          }
          .onEnded { _ in
            // 드래그 끝났으니 비디오 재생 재지정
            onEndChange()
            updateOriginalValue()
          })

      // Right Thumb Handle
      thumbView(
        height: sliderSize.height,
        position: rightThumbPoint,
        isLeftThumb: false)
        .highPriorityGesture(DragGesture().onChanged { dragValue in
          let dragLocation = dragValue.location
          let xThumbOffset = min(max(CGFloat(leftThumbLocation), dragLocation.x), sliderSize.width)

          var newValue = xThumbOffset / stepWidthInPixel // convert back the value bound
          newValue = min(newValue, sliderBounds.upperBound)

          // Stop the range thumbs from colliding each other
          if newValue > currentValue?.wrappedValue.lowerBound ?? 0 {
            if newValue - (currentValue?.wrappedValue.lowerBound ?? 0) <= 15 {
              currentValue?.wrappedValue = (currentValue?.wrappedValue.lowerBound ?? 0) ... newValue
            } else {
              currentValue?.wrappedValue = (currentValue?.wrappedValue.lowerBound ?? 0) ...
                (currentValue?.wrappedValue.lowerBound ?? 0) + 15
            }
          }
        }.onEnded { _ in
          onEndChange()
          updateOriginalValue()
        })

      // Area to move entire range
      backgroundBetweenThumbs(from: leftThumbLocation, width: editedDurationPixel)
        .gesture(
          DragGesture().onChanged { dragValue in
            let draggedOffset = dragValue.location.x - dragValue.startLocation.x
            let draggedTime = draggedOffset / stepWidthInPixel

            // newValue 계산
            let newLowerBound = originalValue.lowerBound + draggedTime
            let newUpperBound = originalValue.upperBound + draggedTime

            // 범위를 변경하되, 범위가 sliderBounds 내에 머무르도록 제한
            if let totalduration = editorVM.currentVideo?.totalDuration {
              let clampedLowerBound = min(max(newLowerBound, sliderBounds.lowerBound), sliderBounds.upperBound - totalduration)
              let clampedUpperBound = min(max(newUpperBound, sliderBounds.lowerBound + totalduration), sliderBounds.upperBound)
              currentValue?.wrappedValue = clampedLowerBound ... clampedUpperBound
            }
          }.onEnded { _ in
            updateOriginalValue()
          })

      // Draggable Current Time indicator
      timeIndicator(height: sliderSize.height, by: stepWidthInPixel)
        .highPriorityGesture(
          DragGesture().onChanged { dragValue in
            videoPlayer.scrubState = .scrubStarted
            let dragLocation = dragValue.location
            let controllerOffset = min(max(CGFloat(leftThumbLocation), dragLocation.x), CGFloat(rightThumbLocation))
            videoPlayer.currentTime = controllerOffset / stepWidthInPixel
            videoPlayer.scrubState = .scrubEnded(videoPlayer.currentTime)
            editorVM.setTools()
          }.onEnded { _ in
            videoPlayer.scrubState = .scrubEnded(videoPlayer.currentTime)
            editorVM.setTools()
          })
    }
    .compositingGroup()
  }

  @ViewBuilder
  func thumbView(height: CGFloat, position: CGPoint, isLeftThumb: Bool) -> some View {
    let width: CGFloat = 24
    Rectangle()
      .fill(isLeftThumb ? Color.Blue_Default : Color.Secondary_Default)
      .frame(width: width, height: height)
      .contentShape(Rectangle())
      .cornerRadius(8, corners: isLeftThumb ? [.topLeft, .bottomLeft] : [.topRight, .bottomRight])
      .overlay {
        Image(systemName: isLeftThumb ? "chevron.left" : "chevron.right")
          .padding(.leading, isLeftThumb ? 2 : 0)
          .padding(.trailing, isLeftThumb ? 0 : 2)
          .foregroundColor(.white)
      }
      .offset(x: position.x + CGFloat(isLeftThumb ? -width : 0))
  }

  @ViewBuilder
  func lineBetweenThumbs(from: CGFloat, width: CGFloat) -> some View {
    Rectangle()
      .strokeBorder(LinearGradient.primaryGradient, lineWidth: strokeWidth)
      .frame(width: max(width + strokeWidth * 2, strokeWidth * 2))
      .offset(x: from - strokeWidth)
  }

  @ViewBuilder
  func backgroundBetweenThumbs(from: CGFloat, width: CGFloat) -> some View {
    Rectangle()
      .fill(Color.black.opacity(0.01))
      .frame(width: width)
      .offset(x: from)
  }

  @ViewBuilder
  func timeIndicator(height: CGFloat, by: CGFloat) -> some View {
    Rectangle()
      .cornerRadius(100, corners: .allCorners)
      .foregroundStyle(Color.white)
      .frame(width: UIScreen.getWidth(strokeWidth), height: height - strokeWidth)
      .contentShape(
        Rectangle()
          .scale(2, anchor: .leading)
          .scale(2, anchor: .trailing))
      .offset(x: videoPlayer.currentTime * by - strokeWidth / 2)
      .onAppear {
        print(videoPlayer.currentTime)
      }
  }

  func increaseRange(range: ClosedRange<Double>, by: Double) -> ClosedRange<Double> {
    (range.lowerBound + by) ... (range.upperBound + by)
  }

  func updateOriginalValue() {
    originalValue = currentValue?.wrappedValue ?? originalValue
  }
}

//// MARK: - RangeSliderView_Previews
//
// struct RangeSliderView_Previews: PreviewProvider {
//  static var previews: some View {
//    RangedSliderView(
//      value: .constant(16 ... 60),
//      currentTime: .constant(1), bounds: 1 ... 100,
//      onEndChange: {}
//    )
//    .frame(height: 60)
//    .padding()
//  }
// }
