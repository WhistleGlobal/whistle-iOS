//
//  Alert.swift
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
  var alertStyle: AlertStyle
  let title: String?
  let content: String?
  let cancelText: String?
  let destructiveText: String?
  let submitText: String?

  let cancelAction: (() -> Void)?
  let destructiveAction: (() -> Void)?
  let submitAction: (() -> Void)?

  init(
    alertStyle: AlertStyle = .stack,
    title: String? = nil,
    content: String? = nil,
    cancelText: String? = nil,
    destructiveText: String? = nil,
    submitText: String? = nil,
    cancelAction: (() -> Void)? = nil,
    destructiveAction: (() -> Void)? = nil,
    submitAction: (() -> Void)? = nil)
  {
    self.alertStyle = alertStyle
    self.title = title
    self.content = content
    self.cancelText = cancelText
    self.destructiveText = destructiveText
    self.submitText = submitText
    self.cancelAction = cancelAction
    self.destructiveAction = destructiveAction
    self.submitAction = submitAction
  }

  var body: some View {
    ZStack {
      Color.black.opacity(0.64)
      VStack(spacing: 0) {
        if let title {
          Text(title)
            .fontSystem(fontDesignSystem: .subtitle2_KO)
            .foregroundStyle(Color.LabelColor_Primary_Dark)
            .padding(.bottom, UIScreen.getHeight(8))
            .padding(.horizontal, UIScreen.getWidth(16))
            .multilineTextAlignment(.center)
        }
        if let content {
          Text(content)
            .foregroundStyle(Color.LabelColor_Secondary_Dark)
            .lineLimit(nil) // 줄바꿈을 제한하지 않음
            .multilineTextAlignment(.center) // 중앙 정렬
            .fixedSize(horizontal: false, vertical: true) // 너비를 넘어갈 경우 자동 줄바꿈
            .padding(.horizontal, UIScreen.getWidth(16))
            .padding(.bottom, UIScreen.getHeight(22))
        }
        Divider().overlay(Color.Border_Default)
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
    }
    .ignoresSafeArea()
  }
}

extension AlertPopup {
  @ViewBuilder
  func alerButton() -> some View {
    switch alertStyle {
    case .stack:
      VStack(spacing: 0) {
        Button {
          destructiveAction?()
        } label: {
          if let destructiveText {
            Text(destructiveText)
              .foregroundStyle(Color.Danger)
              .fontSystem(fontDesignSystem: .subtitle2_KO)
              .vCenter()
              .hCenter()
              .padding(.vertical, UIScreen.getHeight(10))
          }
        }
        Divider().overlay(Color.Border_Default)
        Button {
          cancelAction?()
        } label: {
          if let cancelText {
            Text(cancelText)
              .foregroundStyle(Color.Info)
              .fontSystem(fontDesignSystem: .body1_KO)
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
          cancelAction?()
        } label: {
          if let cancelText {
            Text(cancelText)
              .foregroundStyle(Color.Info)
              .fontSystem(fontDesignSystem: .body1_KO)
              .hCenter()
              .padding(.vertical, UIScreen.getHeight(10))
          }
        }
        Divider()
          .overlay(Color.Border_Default)
        Button {
          destructiveAction?()
        } label: {
          if let destructiveText {
            Text(destructiveText)
              .foregroundStyle(Color.Danger)
              .fontSystem(fontDesignSystem: .subtitle2_KO)
              .hCenter()
              .padding(.vertical, UIScreen.getHeight(10))
          }
        }
      }
      .fixedSize(horizontal: false, vertical: true)
    case .submit:
      Button {
        submitAction?()
      } label: {
        if let submitText {
          Text(submitText)
            .foregroundStyle(Color.Info)
            .fontSystem(fontDesignSystem: .subtitle2_KO)
            .hCenter()
            .padding(.vertical, UIScreen.getHeight(10))
        }
      }
    }
  }
}

// #Preview {
//  AlertPopup(
//    title: "A Short Title Is Best",
//    content: "A message should be short,\ncomplete sentence",
//    cancelText: "취소",
//    destructiveText: "삭제",
//    submitText: "완료")
// }
