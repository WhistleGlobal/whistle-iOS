//
//  ProfileAlert.swift
//  Whistle
//
//  Created by ChoiYujin on 9/3/23.
//

import SwiftUI

// MARK: - ProfileAlert

struct ProfileAlert: View {

  let cancelAction: () -> Void
  let updateAction: () -> Void

  var body: some View {
    VStack(spacing: 0) {
      Spacer()
      ZStack {
        VStack(spacing: 0) {
          profileAlertView()
        }
        RoundedRectangle(cornerRadius: 14)
          .stroke(lineWidth: 1)
          .foregroundStyle(
            LinearGradient.Border_Glass)
          .frame(maxWidth: .infinity, maxHeight: .infinity)

        VStack(spacing: 0) {
          Spacer().frame(height: 150)
          Rectangle()
            .frame(width: 270, height: 1)
            .foregroundStyle(LinearGradient.Border_Glass)
          Rectangle()
            .frame(width: 1, height: 45)
            .foregroundStyle(LinearGradient.Border_Glass)
        }
      }
      .frame(width: 270, height: 195)

      Spacer()
    }
    .frame(maxWidth: .infinity)
    .background(Color.black.opacity(0.8))
  }
}

extension ProfileAlert {

  @ViewBuilder
  func glassMorphicCard(width: CGFloat, height: CGFloat) -> some View {
    ZStack {
      RoundedRectangle(cornerRadius: 32, style: .continuous)
        .fill(Color.black.opacity(0.3))
      CustomBlurView(effect: .systemUltraThinMaterialLight) { view in
        // FIXME: - 피그마와 비슷하도록 값 고치기
        view.saturationAmout = 2.2
        view.gaussianBlurRadius = 36
      }
    }
    .frame(width: width, height: height)
  }

  @ViewBuilder
  func glassAlertTop() -> some View {
    glassMorphicCard(width: 270, height: 151)
      .cornerRadius(14, corners: [.topLeft, .topRight])
  }

  @ViewBuilder
  func glassAlertBottomRight() -> some View {
    glassMorphicCard(width: 135, height: 45)
      .cornerRadius(14, corners: [.bottomRight])
  }

  @ViewBuilder
  func glassAlertBottomLeft() -> some View {
    glassMorphicCard(width: 135, height: 45)
      .cornerRadius(14, corners: [.bottomLeft])
  }

  @ViewBuilder
  func profileAlertView() -> some View {
    VStack(spacing: 16) {
      Text("정말 사용자 ID를\n 변경하시겠습니까?")
        .fontSystem(fontDesignSystem: .subtitle2_KO)
        .foregroundColor(.LabelColor_Primary_Dark)
      Text("30일마다 한 번씩 사용자 ID를\n 변경할 수 있습니다.")
        .fontSystem(fontDesignSystem: .body2_KO)
        .foregroundColor(.LabelColor_Secondary_Dark)
    }
    .frame(width: 270, height: 151)
    .multilineTextAlignment(.center)
    .background(
      glassAlertTop())
    HStack(spacing: 0) {
      Button {
        cancelAction()
      } label: {
        glassAlertBottomLeft()
      }
      .overlay {
        Text("취소")
          .fontSystem(fontDesignSystem: .body1_KO)
          .foregroundColor(.Primary_Default)
      }
      Button {
        updateAction()
      } label: {
        glassAlertBottomRight()
      }
      .overlay {
        Text("변경")
          .fontSystem(fontDesignSystem: .subtitle2_KO)
          .foregroundColor(.Danger)
      }
    }
  }
}
