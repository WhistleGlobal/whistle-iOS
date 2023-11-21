//
//  Carousel.swift
//  Whistle
//
//  Created by ChoiYujin on 11/9/23.
//

import Foundation
import SwiftUI

struct Carousel<Content: View>: View {
  typealias PageIndex = Int

  let pageCount: Int
  let visibleEdgeSpace: CGFloat
  let spacing: CGFloat
  @State var isLoaded = false
  @Binding var currentIndex: Int
  @Binding private var isDragging: Bool
  let content: (PageIndex) -> Content

  @GestureState var dragOffset: CGFloat = 0

  init(
    pageCount: Int,
    visibleEdgeSpace: CGFloat,
    spacing: CGFloat,
    currentIndex: Binding<Int>,
    isDragging: Binding<Bool>,
    @ViewBuilder content: @escaping (PageIndex) -> Content)
  {
    self.pageCount = pageCount
    self.visibleEdgeSpace = visibleEdgeSpace
    self.spacing = spacing
    _currentIndex = currentIndex
    _isDragging = isDragging
    self.content = content
  }

  var body: some View {
    GeometryReader { proxy in
      let baseOffset: CGFloat = spacing + visibleEdgeSpace
      let pageWidth: CGFloat = proxy.size.width - (visibleEdgeSpace + spacing) * 2
      let offsetX: CGFloat = baseOffset + CGFloat(currentIndex) * -pageWidth + CGFloat(currentIndex) * -spacing + dragOffset

      HStack(spacing: spacing) {
        ForEach(0..<pageCount, id: \.self) { pageIndex in
          content(pageIndex)
            .frame(
              width: pageWidth,
              height: proxy.size.height)
        }
        .contentShape(Rectangle())
        .animation(isLoaded ? .spring(duration: 0.4) : .linear(duration: 0.0))
        .allowsHitTesting(!isDragging)
      }
      .offset(x: offsetX)
      .gesture(
        DragGesture()
          .updating($dragOffset) { value, out, _ in
            isDragging = true
            out = value.translation.width
          }
          .onChanged { _ in
            isDragging = true
          }
          .onEnded { value in
            let offsetX = value.translation.width
            let progress = -offsetX / pageWidth
            let increment = Int(progress.rounded())
            currentIndex = max(min(currentIndex + increment, pageCount - 1), 0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
              isDragging = false
            }
          })
    }
    .onAppear {
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        isLoaded = true
      }
    }
  }
}
