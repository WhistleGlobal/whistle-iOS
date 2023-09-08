//
//  ProfileEditIntroduceView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/3/23.
//

import Combine
import SwiftUI

// MARK: - ProfileEditIntroduceView

struct ProfileEditIntroduceView: View {

  @Environment(\.dismiss) var dismiss
  @Binding var showToast: Bool
  @EnvironmentObject var apiViewModel: APIViewModel
  @Binding var introduce: String

  var body: some View {
    VStack(spacing: 0) {
      Divider().frame(width: UIScreen.width)
      TextField("소개글을 입력해주세요.", text: $apiViewModel.myProfile.introduce, axis: .vertical)
        .fontSystem(fontDesignSystem: .body1_KO)
        .frame(height: 100, alignment: .top)
        .multilineTextAlignment(.leading)
        .background(.white)
        .onReceive(Just(introduce)) { _ in limitText(40) }
        .overlay(alignment: .bottom) {
          Text("\(introduce.count)/40자")
            .fontSystem(fontDesignSystem: .body1_KO)
            .foregroundColor(.Disable_Placeholder)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.vertical, 20)
      Divider().frame(width: UIScreen.width)
      Spacer()
    }
    .padding(.horizontal, 16)
    .navigationBarBackButtonHidden()
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button {
          Task {
            await apiViewModel.requestMyProfile()
            dismiss()
          }
        } label: {
          Image(systemName: "chevron.backward")
            .foregroundColor(.LabelColor_Primary)
        }
      }
      ToolbarItem(placement: .principal) {
        Text("소개")
          .fontSystem(fontDesignSystem: .subtitle2_KO)
      }
      ToolbarItem(placement: .confirmationAction) {
        Button {
          Task {
            await apiViewModel.updateMyProfile()
            dismiss()
            showToast = true
          }
        } label: {
          Text("완료")
            .foregroundColor(true ? .Info : .Disable_Placeholder)
            .fontSystem(fontDesignSystem: .subtitle2_KO)
        }
        .disabled(false)
      }
    }
  }
}

extension ProfileEditIntroduceView {

  // Function to keep text length in limits
  func limitText(_ upper: Int) {
    if introduce.count > upper {
      introduce = String(introduce.prefix(upper))
    }
  }

}
