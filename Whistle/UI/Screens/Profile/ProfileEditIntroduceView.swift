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
  @EnvironmentObject var userViewModel: UserViewModel

  var body: some View {
    VStack(spacing: 0) {
      Divider().frame(width: UIScreen.width)
      TextField("소개글을 입력해주세요.", text: $userViewModel.myProfile.introduce, axis: .vertical)
        .fontSystem(fontDesignSystem: .body1_KO)
        .frame(height: 100, alignment: .top)
        .multilineTextAlignment(.leading)
        .background(.white)
        .onReceive(Just(userViewModel.myProfile.introduce)) { _ in limitText(40) }
        .overlay(alignment: .bottom) {
          Text("\(userViewModel.myProfile.introduce.count)/40자")
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
          dismiss()
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
          userViewModel.updateMyProfile()
          dismiss()
          showToast = true
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
    if userViewModel.myProfile.introduce.count > upper {
      userViewModel.myProfile.introduce = String(userViewModel.myProfile.introduce.prefix(upper))
    }
  }

}
