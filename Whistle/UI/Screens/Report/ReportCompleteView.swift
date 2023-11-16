//
//  ReportCompleteView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/14/23.
//

import SwiftUI

struct ReportCompleteView: View {
  @Binding var goReport: Bool

  var body: some View {
    VStack {
      HStack {
        Button {
          goReport = false
        } label: {
          Image(systemName: "xmark")
            .resizable()
            .scaledToFit()
            .frame(width: 16, height: 16)
            .foregroundColor(.labelColorPrimary)
        }
        Spacer()
      }
      .padding(.vertical, 14)
      .padding(.horizontal, 16)
      Spacer()

      Image(systemName: "checkmark.circle")
        .resizable()
        .scaledToFit()
        .frame(width: 45, height: 45)
        .padding(3)
        .foregroundColor(.Primary_Default)
        .padding(.bottom, 32)
      Text("알려주셔서 감사합니다.")
        .fontSystem(fontDesignSystem: .subtitle1)
        .foregroundColor(.labelColorPrimary)
        .padding(.bottom, 12)
      Text("회원님의 소중한 의견은 Whistle 커뮤니티를\n 안전하게 유지하는 데 도움이 됩니다.")
        .multilineTextAlignment(.center)
        .foregroundColor(.labelColorSecondary)
        .padding(.bottom, 64)
      Spacer()
    }
    .background(Color.backgroundDefault)
    .navigationBarBackButtonHidden()
    .onAppear {
      DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
        goReport = false
      }
    }
  }
}
