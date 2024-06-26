//
//  ToastMessageView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/3/23.
//

import SwiftUI

// MARK: - ToastMessageView

struct ToastMessageView: View {
  @StateObject var toastViewModel = ToastViewModel.shared
  @State private var timer: Timer?

  var body: some View {
    if toastViewModel.showToast {
      VStack {
        Spacer()
        HStack {
          Text(toastViewModel.message)
            .fontSystem(fontDesignSystem: .body1)
            .foregroundColor(.Gray10)
            .padding(.horizontal, 24)
          if toastViewModel.isCancellable {
            Spacer()
            Button(ToastMessages().undo) {
              toastViewModel.cancelCancellableAction()
              withAnimation {
                toastViewModel.showToast = false
              }
            }
            .fontSystem(fontDesignSystem: .body2)
            .foregroundColor(.Info)
            .padding(.horizontal, 24)
          }
        }
        .frame(height: 56)
        .frame(maxWidth: .infinity)
//        .background(Color.Gray70_Dark)
        .background(disabledGlass(cornerRadius: 8))
        .overlay {
          RoundedRectangle(cornerRadius: 8)
            .stroke(lineWidth: 1)
            .foregroundColor(.Border_Default_Dark)
        }
      }
      .padding(.horizontal, 16)
      .padding(.bottom, toastViewModel.padding)
      .transition(.move(edge: .bottom).animation(.smooth(duration: 1)).combined(with: .opacity.animation(.smooth(duration: 0.5))))
      .onReceive(toastViewModel.$message, perform: { _ in
        if toastViewModel.showToast {
          timer?.invalidate()
          timer = nil
        }
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
          withAnimation {
            toastViewModel.showToast = false
          }
          if toastViewModel.isCancellable, !toastViewModel.isCancelled {
            toastViewModel.cancellableAction?()
          } else {
            toastViewModel.undoAction?()
          }
          timer?.invalidate()
          timer = nil
        }
      })
    }
  }
}
