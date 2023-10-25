//
//  ToastMessage.swift
//  Whistle
//
//  Created by ChoiYujin on 9/3/23.
//

import SwiftUI

// MARK: - ProfileToastMessage

struct ToastMessageView: View {
  @StateObject var toastViewModel = ToastViewModel.shared

  var body: some View {
    VStack {
      if !toastViewModel.isTop {
        Spacer()
      }
      HStack {
        Text(toastViewModel.message)
          .fontSystem(fontDesignSystem: .body1_KO)
          .foregroundColor(.Gray10)
          .padding(.horizontal, 24)
        if toastViewModel.isCancellable {
          Spacer()
          Button("실행 취소") {
//            toastInfo.toastOpacity = 0.0
            toastViewModel.cancelCancellableAction()
            toastViewModel.showToast = false
          }
          .fontSystem(fontDesignSystem: .body2_KO)
          .foregroundColor(.Info)
          .padding(.horizontal, 24)
        }
      }
      .frame(height: 56)
      .frame(maxWidth: .infinity)
      .background(Color.Gray70_Dark)
      .cornerRadius(8)
      .overlay {
        RoundedRectangle(cornerRadius: 8)
          .stroke(lineWidth: 1)
          .foregroundColor(.Border_Default_Dark)
      }
      .opacity(toastViewModel.toastOpacity)
      if toastViewModel.isTop {
        Spacer()
      }
    }
    .padding(.horizontal, 16)
    .padding(toastViewModel.isTop ? .top : .bottom, toastViewModel.isTop ? 0 : toastViewModel.padding)
    .onChange(of: toastViewModel.showToast) { _ in
      // showToast가 true로 설정되면 토스트 메시지를 표시하도록 설정
      if toastViewModel.showToast {
        withAnimation {
          toastViewModel.toastOpacity = 1.0
        }
        // 일정 시간 후에 토스트 메시지를 숨김
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
          withAnimation {
            toastViewModel.toastOpacity = 0.0
          }
          if toastViewModel.isCancellable, !toastViewModel.isCancelled {
            toastViewModel.cancellableAction?()
          }
          toastViewModel.showToast = false
        }
      }
    }
  }
}
