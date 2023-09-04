//
//  ProfileToastMessage.swift
//  Whistle
//
//  Created by ChoiYujin on 9/3/23.
//

import SwiftUI

// MARK: - ProfileToastMessage

struct ProfileToastMessage: View {

  // MARK: Internal

  let text: String
  @Binding var showToast: Bool

  var body: some View {
    VStack {
      Spacer()
      Text(text)
        .frame(height: 56)
        .frame(maxWidth: .infinity)
        .fontSystem(fontDesignSystem: .body1_KO)
        .foregroundColor(.Gray10)
        .background(Color.Gray70_Dark)
        .cornerRadius(8)
        .opacity(toastOpacity)
    }
    .padding(.horizontal, 16)
    .padding(.bottom, 32)
    .onAppear {
      // showToast가 true로 설정되면 토스트 메시지를 표시하도록 설정
      if showToast {
        toastOpacity = 1.0
        // 일정 시간 후에 토스트 메시지를 숨김
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
          withAnimation {
            toastOpacity = 0.0
          }
          // showToast를 false로 설정하여 다음에 토스트 메시지가 나타나지 않도록 함
          showToast = false
        }
      }
    }
  }

  // MARK: Private

  @State private var toastOpacity = 0.0

}
