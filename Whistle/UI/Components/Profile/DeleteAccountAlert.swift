//
//  DeleteAccountAlert.swift
//  Whistle
//
//  Created by ChoiYujin on 9/18/23.
//

import SwiftUI

// MARK: - DeleteAccountAlert

struct DeleteAccountAlert: View {

  let cancelAction: () -> Void
  let deleteAction: () -> Void

  var body: some View {
    VStack(spacing: 0) {
      Spacer()
      ZStack {
        VStack(spacing: 0) {
          deleteAlertView()
        }
        RoundedRectangle(cornerRadius: 14)
          .stroke(lineWidth: 1)
          .foregroundStyle(LinearGradient.Border_Glass)
          .frame(maxWidth: .infinity, maxHeight: .infinity)

        VStack(spacing: 0) {
          Spacer().frame(height: 138)
          Rectangle()
            .frame(width: 270, height: 1)
            .foregroundStyle(LinearGradient.Border_Glass)
          Rectangle()
            .frame(width: 1, height: 45)
            .foregroundStyle(LinearGradient.Border_Glass)
        }
      }
      .frame(width: 270, height: 182)

      Spacer()
    }
    .frame(maxWidth: .infinity)
    .background(Color.black.opacity(0.8))
  }
}

extension DeleteAccountAlert {

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
    glassMorphicCard(width: 270, height: 138)
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
  func deleteAlertView() -> some View {
    VStack(spacing: 16) {
      Text("정말 삭제하시겠어요?")
        .fontSystem(fontDesignSystem: .subtitle2_KO)
        .foregroundColor(.LabelColor_Primary_Dark)
      Text("삭제하시면 회원님의 모든 정보와 활동\n기록이 삭제됩니다. 삭제된 정보는\n복구할 수 없으니 신중하게 결정해주세요.")
        .fontSystem(fontDesignSystem: .body2_KO)
        .foregroundColor(.LabelColor_Secondary_Dark)
    }
    .frame(width: 270, height: 138)
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
          .foregroundColor(.Info)
      }
      Button {
        deleteAction()
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
// #Preview {
//  DeleteAccountAlert(cancelAction: { }, deleteAction: { })
// }
