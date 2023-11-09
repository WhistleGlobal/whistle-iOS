//
//  AlertPopup.swift
//  Whistle
//
//  Created by 박상원 on 10/15/23.
//

import SwiftUI

// MARK: - AlertButtonType

enum AlertButtonType {
  case cancel, destructive, submit
}

// MARK: - AlertStyle

enum AlertStyle {
  /// 세로로 쌓이는 버튼 형태
  case stack
  /// 가로로 나열된 두 버튼
  case linear
  /// 단일 버튼
  case submit
}

// MARK: - AlertPopup

/// AlertPopup을 띄우는 View입니다.
///
/// 기존 뷰 전체에 shadow와 alert popup을 띄워 줍니다.
///
/// - Parameters:
///   - alertStyle: .stack, .linear, .submit 세 종류로, 경고창의 타입을 선택할 수 있습니다.
///   - title: 제목 텍스트입니다.
///   - content: 본문 텍스트입니다.
///   - cancelText: 취소 버튼에 들어갈 텍스트입니다. .linear의 왼쪽, .stack의 아래쪽에 들어갑니다.
///   - destructiveText: 빨간색 버튼에 들어갈 텍스트입니다. .linear의 오른쪽, .stack의 위쪽에 들어갑니다.
///   - submitText: .submit 스타일에만 사용되는 텍스트입니다.
///   - cancelAction: 취소 버튼이 수행할 액션을 정의합니다.
///   - destructiveAction: 빨간색 버튼이 수행할 액션을 정의합니다.
///   - submitAction: 완료 버튼이 수행할 액션을 정의합니다.
///
struct AlertPopup: View {
  @ObservedObject var alertViewModel = AlertViewModel.shared

  var body: some View {
    ZStack {
      if alertViewModel.showAlert {
        DimsThick()
          .ignoresSafeArea()
          .transition(
            !alertViewModel.isImmediateDismiss
              ? .asymmetric(
                insertion: .opacity.animation(.smooth(duration: 0.5)),
                removal: .opacity.animation(.spring(blendDuration: 0.3)))
              : .asymmetric(
                insertion: .opacity.animation(.smooth(duration: 0.5)),
                removal: .opacity))
      }
      if alertViewModel.showAlert {
        VStack(spacing: 0) {
          if let title = alertViewModel.title {
            Text(title)
              .fontSystem(fontDesignSystem: .subtitle2)
              .foregroundStyle(Color.LabelColor_Primary_Dark)
              .padding(.bottom, alertViewModel.content != nil ? UIScreen.getHeight(8) : UIScreen.getHeight(20))
              .padding(.horizontal, UIScreen.getWidth(16))
              .multilineTextAlignment(.center)
          }
          if let content = alertViewModel.content {
            Text(content)
              .fontSystem(fontDesignSystem: .body2)
              .foregroundStyle(Color.LabelColor_Secondary_Dark)
              .lineLimit(nil) // 줄바꿈을 제한하지 않음
              .multilineTextAlignment(.center) // 중앙 정렬
              .fixedSize(horizontal: false, vertical: true) // 너비를 넘어갈 경우 자동 줄바꿈
              .padding(.horizontal, UIScreen.getWidth(16))
              .padding(.bottom, UIScreen.getHeight(22))
          }
          Divider().overlay(Color.Border_Default_Light)
          alerButton()
        }
        .padding(.top, UIScreen.getHeight(24)) // 텍스트와 경계 사이의 여백 추가
        .frame(width: UIScreen.getWidth(270))
        .background {
          RoundedRectangle(cornerRadius: 14)
            .fill(.clear)
            .background {
              glassMorphicView(cornerRadius: 14)
            }
        }
        .overlay {
          RoundedRectangle(cornerRadius: 14)
            .stroke(LinearGradient.Border_Glass)
        }
        .transition(
          !alertViewModel.isImmediateDismiss
            ? .asymmetric(
              insertion: .scale(scale: 1.1).animation(.smooth(duration: 0.25))
                .combined(with: .opacity.animation(.smooth(duration: 0.5))),
              removal: .opacity.animation(.spring(blendDuration: 0.3)))
            : .asymmetric(
              insertion: .scale(scale: 1.1).animation(.smooth(duration: 0.25))
                .combined(with: .opacity.animation(.smooth(duration: 0.5))),
              removal: .opacity))
        .ignoresSafeArea()
      }
    }
    .ignoresSafeArea()
  }
}

extension AlertPopup {
  @ViewBuilder
  func alerButton() -> some View {
    switch alertViewModel.alertStyle {
    case .stack:
      VStack(spacing: 0) {
        Button {
          alertViewModel.destructiveAction?()
          alertViewModel.dismissAlert()
        } label: {
          if let destructiveText = alertViewModel.destructiveText {
            Text(destructiveText)
              .foregroundStyle(Color.Danger)
              .fontSystem(fontDesignSystem: .subtitle2)
              .vCenter()
              .hCenter()
              .padding(.vertical, UIScreen.getHeight(10))
          }
        }
        Divider().overlay(Color.Border_Default_Light)
        Button {
          alertViewModel.cancelAction?()
          alertViewModel.dismissAlert()
        } label: {
          if let cancelText = alertViewModel.cancelText {
            Text(cancelText)
              .foregroundStyle(Color.Info)
              .fontSystem(fontDesignSystem: .body1)
              .vCenter()
              .hCenter()
              .padding(.vertical, UIScreen.getHeight(10))
          }
        }
      }
      .fixedSize(horizontal: false, vertical: true)
    case .linear:
      HStack(spacing: 0) {
        Button {
          alertViewModel.cancelAction?()
          alertViewModel.dismissAlert()
        } label: {
          if let cancelText = alertViewModel.cancelText {
            Text(cancelText)
              .foregroundStyle(Color.Info)
              .fontSystem(fontDesignSystem: .body1)
              .hCenter()
              .padding(.vertical, UIScreen.getHeight(10))
          }
        }
        Divider()
          .overlay(Color.Border_Default_Light)
        Button {
          alertViewModel.destructiveAction?()
          alertViewModel.dismissAlert()
        } label: {
          if let destructiveText = alertViewModel.destructiveText {
            Text(destructiveText)
              .foregroundStyle(alertViewModel.isRed ? Color.Danger : Color.Info)
              .fontSystem(fontDesignSystem: .subtitle2)
              .hCenter()
              .padding(.vertical, UIScreen.getHeight(10))
          }
        }
      }
      .fixedSize(horizontal: false, vertical: true)
    case .submit:
      Button {
        alertViewModel.submitAction?()
        alertViewModel.dismissAlert()
      } label: {
        if let submitText = alertViewModel.submitText {
          Text(submitText)
            .foregroundStyle(Color.Info)
            .fontSystem(fontDesignSystem: .subtitle2)
            .hCenter()
            .padding(.vertical, UIScreen.getHeight(10))
        }
      }
    }
  }
}
