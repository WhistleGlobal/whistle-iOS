//
//  MiniAudioVisualizer.swift
//  Whistle
//
//  Created by 박상원 on 11/5/23.
//

import SwiftUI

// MARK: - MiniAudioVisualizer

struct MiniAudioVisualizer: View {
  var body: some View {
    HStack(spacing: 2) {
      ForEach(0 ..< 4, id: \.self) { _ in
        VisualizingRectangle()
      }
    }
    .frame(width: 24, height: 24)
  }
}

// MARK: - VisualizingRectangle

struct VisualizingRectangle: View {
  @State private var heightValue: CGFloat = 0.0

  var body: some View {
    GeometryReader { geo in
      VStack(spacing: 0) {
        Rectangle().fill(.clear)
        Rectangle()
          .fill(.white)
          .cornerRadius(8, corners: [.topLeft, .topRight])
          .frame(height: geo.size.height * heightValue)
      }
      .animation(.easeInOut, value: heightValue)
    }
    .onAppear {
      stepHeight()
    }
  }

  func stepHeight() {
    let delayValue = 0.25
    heightValue = CGFloat.random(in: 0.2 ... 1)
    DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(delayValue)) {
      stepHeight()
    }
  }
}
