//
//  ToastMessage.swift
//  Whistle
//
//  Created by ChoiYujin on 9/3/23.
//

import SwiftUI

// MARK: - ProfileToastMessage

struct ToastMessage: View {
  // MARK: Internal

  let text: String
  let toastPadding: CGFloat
  @State var isTopAlignment = false
  @Binding var showToast: Bool

  var body: some View {
    VStack {
      if !isTopAlignment {
        Spacer()
      }
      Text(text)
        .frame(height: 56)
        .frame(maxWidth: .infinity)
        .fontSystem(fontDesignSystem: .body1_KO)
        .foregroundColor(.Gray10)
        .background(Color.Gray70_Dark)
        .cornerRadius(8)
        .opacity(toastOpacity)
      if isTopAlignment {
        Spacer()
      }
    }
    .padding(.horizontal, 16)
    .padding(isTopAlignment ? .top : .bottom, isTopAlignment ? 0 : toastPadding)
    .onAppear {
      // showToast가 true로 설정되면 토스트 메시지를 표시하도록 설정
      if showToast {
        toastOpacity = 1.0
        // 일정 시간 후에 토스트 메시지를 숨김
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
          withAnimation {
            toastOpacity = 0.0
          }
          showToast = false
        }
      }
    }
  }

  // MARK: Private

  @State private var toastOpacity = 0.0
}
