//
//  CancelableToastMessage.swift
//  Whistle
//
//  Created by ChoiYujin on 9/19/23.
//

import SwiftUI

struct CancelableToastMessage: View {

  let text: String
  let paddingBottom: CGFloat
  let action: () -> Void
  @Binding var showToast: Bool

  var body: some View {
    VStack {
      Spacer()
      HStack {
        Text(text)
          .fontSystem(fontDesignSystem: .body1_KO)
          .foregroundColor(.Gray10)
          .padding(.horizontal, 24)
        Spacer()
        Button("실행 취소") {
          isExecutable = false
          showToast = false
        }
        .fontSystem(fontDesignSystem: .body2_KO)
        .foregroundColor(.Info)
        .padding(.horizontal, 24)
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
      .opacity(toastOpacity)
    }
    .padding(.horizontal, 16)
    .padding(.bottom, paddingBottom)
    .onAppear {
      if showToast {
        toastOpacity = 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
          withAnimation {
            toastOpacity = 0.0
          }
          if isExecutable {
            action()
          }
          showToast = false
        }
      }
    }
  }

  @State private var toastOpacity = 0.0
  @State private var isExecutable = true
}

#Preview {
  CancelableToastMessage(text: "텍스트", paddingBottom: 40, action: {
    log("action execute")
  }, showToast: .constant(true))
}
