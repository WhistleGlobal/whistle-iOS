//
//  NewTimelineSlider.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import SwiftUI

// MARK: - TimelineSlider

struct TimelineSlider<T: View>: View {
  @State private var lastOffset: CGFloat = 0
  var bounds: ClosedRange<Double>
  @Binding var value: Double
  @State var isChange = false
  @State var offset: CGFloat = 0
  @State var draggedOffset: CGFloat = 0
  @State var accumulatedOffset: CGFloat = 0
  var frameWidth: CGFloat = 56
  @ViewBuilder
  var frameView: () -> T
  let onChange: () -> Void

  var body: some View {
    GeometryReader { proxy in
      let sliderViewYCenter = proxy.size.height / 2
      // View를 움직이는 offset.
      let sliderPositionX = proxy.size.width / 2 + frameWidth / 2 + offset
      ZStack {
        frameView()
          .frame(width: frameWidth, height: proxy.size.height - 5)
          .position(x: sliderPositionX, y: sliderViewYCenter)
        HStack(spacing: 0) {
          Capsule()
            .fill(Color.white)
            .frame(width: 4, height: proxy.size.height)
        }
        .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 0)
      }
      .frame(width: proxy.size.width, height: proxy.size.height)
      .contentShape(Rectangle())

      .gesture(
        DragGesture(minimumDistance: 1)
          .onChanged { gesture in
            isChange = true
            print("sliderPosition: \(sliderPositionX), \(sliderViewYCenter)")
            let translationWidth = gesture.translation.width
            let newDraggedOffset = accumulatedOffset + translationWidth

            draggedOffset = min(0, max(newDraggedOffset, -frameWidth))
            offset = draggedOffset
            // upperBound: 영상 끝초, lowerBound: 영상 첫초
            // newValue:
            let newValue = (bounds.upperBound - bounds.lowerBound) * (offset / frameWidth) - bounds.lowerBound
            value = abs(newValue)
            onChange()
          }
          .onEnded { value in
            isChange = false
            let newAccumulatedOffset = accumulatedOffset + value.translation.width
            accumulatedOffset = min(0, max(newAccumulatedOffset, -frameWidth))
          })
      .animation(.easeIn, value: offset)
      .onChange(of: value) { _ in
        setOffset()
      }
    }
  }
}

// MARK: - NewTimelineSlider_Previews

struct NewTimelineSlider_Previews: PreviewProvider {
  @State static var curretTime = 0.0
  static var previews: some View {
    TimelineSlider(bounds: 5 ... 34, value: $curretTime, frameView: {
      Rectangle()
        .fill(Color.secondary)
    }, onChange: { })
      .frame(height: 80)
  }
}

extension TimelineSlider {
  private func setOffset() {
    if !isChange {
      offset = ((-value + bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound)) * frameWidth
    }
  }
}
