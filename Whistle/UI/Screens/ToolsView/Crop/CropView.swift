//
//  CropView.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import SwiftUI

// MARK: - CropView

struct CropView<T: View>: View {
  @State private var position: CGPoint = .zero
  @State var size: CGSize = .zero
  @State var clipped = false
  let originalSize: CGSize
  var rotation: Double?
  var isMirror: Bool
  var setFrameScale = false
  var frameScale: CGFloat = 1

  @ViewBuilder
  var frameView: () -> T
  private let lineWidth: CGFloat = 2

  var body: some View {
    ZStack {
      frameView()
        .cornerRadius(12)
    }
    .frame(width: originalSize.width, height: originalSize.height)
    .border(.clear)
    .rotationEffect(.degrees(rotation ?? 0))
    .rotation3DEffect(.degrees(isMirror ? 180 : 0), axis: (x: 0, y: 1, z: 0))
  }
}

// MARK: - CropView_Previews

struct CropView_Previews: PreviewProvider {
  @State static var size: CGSize = .init(width: 250, height: 450)
  static let originalSize: CGSize = .init(width: 300, height: 600)
  static var previews: some View {
    GeometryReader { proxy in
      CropView(originalSize: originalSize, rotation: 0, isMirror: false) {
        Rectangle()
          .fill(Color.secondary)
      }
      .allFrame()
      .frame(height: proxy.size.height / 1.45, alignment: .center)
    }
  }
}

// MARK: - CropFrame

struct CropFrame: Shape {
  let isActive: Bool
  let currentPosition: CGSize
  let size: CGSize
  func path(in rect: CGRect) -> Path {
    guard isActive else { return Path(rect) }

    let size = CGSize(width: size.width, height: size.height)
    let origin = CGPoint(x: rect.midX - size.width / 2, y: rect.midY - size.height / 2)
    return Path(CGRect(origin: origin, size: size).integral)
  }
}

// MARK: - CropImage

struct CropImage<T: View>: View {
  let originalSize: CGSize
  @Binding var frameSize: CGSize
  @State private var currentPosition: CGSize = .zero
  @State private var newPosition: CGSize = .zero
  @State private var clipped = false

  @ViewBuilder
  var frameView: () -> T

  var body: some View {
    VStack {
      ZStack {
        frameView()
          .offset(x: currentPosition.width, y: currentPosition.height)
        Rectangle()
          .fill(Color.black.opacity(0.3))
          .frame(width: frameSize.width, height: frameSize.height)
          .overlay(Rectangle().stroke(Color.white, lineWidth: 2))
      }
      .clipShape(
        CropFrame(isActive: clipped, currentPosition: currentPosition, size: frameSize))
      .onChange(of: frameSize) { _ in
        currentPosition = .zero
        newPosition = .zero
      }

      Button(action: { clipped.toggle() }) {
        Text("Crop Image")
          .padding(.all, 10)
          .background(Color.blue)
          .foregroundColor(.white)
          .shadow(color: .gray, radius: 1)
          .padding(.top, 50)
      }
    }
  }
}

extension Comparable {
  func bounded(lowerBound: Self, uppderBound: Self) -> Self {
    max(lowerBound, min(self, uppderBound))
  }
}
