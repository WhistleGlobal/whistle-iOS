//
//  ReportAlert.swift
//  Whistle
//
//  Created by ChoiYujin on 9/14/23.
//

import SwiftUI

// MARK: - ReportAlert

struct ReportAlert: View {
  let cancelAction: () -> Void
  let reportAction: () -> Void

  var body: some View {
    VStack(spacing: 0) {
      Spacer()
      ZStack {
        VStack(spacing: 0) {
          reportAlertView()
        }
        .overlay {
          RoundedRectangle(cornerRadius: 14)
            .stroke(lineWidth: 1)
            .foregroundStyle(
              LinearGradient.Border_Glass)
        }
        VStack(spacing: 0) {
          Spacer().frame(height: 70)
          Rectangle()
            .frame(width: 270, height: 1)
            .foregroundStyle(LinearGradient.Border_Glass)
          Rectangle()
            .frame(width: 1, height: 45)
            .foregroundStyle(LinearGradient.Border_Glass)
        }
      }
      Spacer()
    }
    .frame(maxWidth: .infinity)
    .background(Color.black.opacity(0.8))
  }
}

extension ReportAlert {
  @ViewBuilder
  func glassMorphicAlert(width: CGFloat, height: CGFloat) -> some View {
    ZStack {
      RoundedRectangle(cornerRadius: 32, style: .continuous)
        .fill(Color.black.opacity(0.3))
      CustomBlurEffect(effect: .systemUltraThinMaterialLight) { view in
        view.saturationAmount = 2.2
        view.gaussianBlurRadius = 36
      }
    }
    .frame(width: width, height: height)
  }

  @ViewBuilder
  func glassAlertTop() -> some View {
    glassMorphicAlert(width: 270, height: 70)
      .cornerRadius(14, corners: [.topLeft, .topRight])
  }

  @ViewBuilder
  func glassAlertBottomRight() -> some View {
    glassMorphicAlert(width: 135, height: 45)
      .cornerRadius(14, corners: [.bottomRight])
  }

  @ViewBuilder
  func glassAlertBottomLeft() -> some View {
    glassMorphicAlert(width: 135, height: 45)
      .cornerRadius(14, corners: [.bottomLeft])
  }

  @ViewBuilder
  func reportAlertView() -> some View {
    VStack {
      Text("정말 신고하시겠습니까?")
    }
    .foregroundColor(.LabelColor_Primary_Dark)
    .frame(width: 270, height: 70)
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
        reportAction()
      } label: {
        glassAlertBottomRight()
      }
      .overlay {
        Text("신고")
          .fontSystem(fontDesignSystem: .subtitle2_KO)
          .foregroundColor(.Danger)
      }
    }
  }
}
