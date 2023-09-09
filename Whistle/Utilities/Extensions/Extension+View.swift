//
//  Extension+View.swift
//  Whistle
//
//  Created by ChoiYujin on 8/29/23.
//

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
      .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
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
