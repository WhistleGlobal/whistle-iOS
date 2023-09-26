//
//  CircularProgressBar.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/13.
//

import SwiftUI

// MARK: - CircularProgressBar

struct CircularProgressBar: View {
  var progress: Double

  @State private var animatedProgress = 0.0 // 애니메이션에 사용할 상태 변수

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        Circle()
          .stroke(lineWidth: 1.5)
          .foregroundColor(.Dim_Thin)
        Circle()
          .trim(from: 0.0, to: CGFloat(min(animatedProgress, 1.0))) // 애니메이션된 값 사용
          .stroke(style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
          .foregroundColor(.Gray10)
          .rotationEffect(Angle(degrees: 270.0))
      }
      .frame(
        width: min(geometry.size.width, geometry.size.height),
        height: min(geometry.size.width, geometry.size.height))
      .onAppear {
        withAnimation(.linear(duration: 0.5)) { // 애니메이션 설정
          animatedProgress = progress
        }
      }
      .onChange(of: progress) { newValue in
        withAnimation(.linear(duration: 0.5)) { // 값이 변경될 때 애니메이션으로 업데이트
          animatedProgress = newValue
        }
      }
    }
  }
}

// MARK: - CircularProgressBar_Previews

struct CircularProgressBar_Previews: PreviewProvider {
  static var previews: some View {
    CircularProgressBar(progress: 0.9)
  }
}
