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
  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject private var tabbarModel = TabbarModel.shared
  @StateObject private var toastViewModel = ToastViewModel.shared
  @StateObject private var alertViewModel = AlertViewModel.shared

  @State var introduce = ""

  var body: some View {
    VStack(spacing: 0) {
      Divider().frame(width: UIScreen.width)
      TextField("소개글을 입력해주세요.", text: $introduce, axis: .vertical)
        .fontSystem(fontDesignSystem: .body1)
        .frame(height: 100, alignment: .top)
        .multilineTextAlignment(.leading)
        .onReceive(Just(introduce)) { _ in limitText(40) }
        .overlay(alignment: .bottom) {
          Text("\(introduce.count)/40자")
            .fontSystem(fontDesignSystem: .body1)
            .foregroundColor(.Disable_Placeholder)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .tint(.Info)
        .padding(.vertical, 20)
      Divider().frame(width: UIScreen.width)
      Spacer()
    }
    .padding(.horizontal, 16)
    .navigationBarBackButtonHidden()
    .navigationTitle(ProfileEditWords().intro)
    .navigationBarTitleDisplayMode(.inline)
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
      ToolbarItem(placement: .confirmationAction) {
        Button {
          Task {
            apiViewModel.myProfile.introduce = introduce.replacingOccurrences(of: "\n", with: "")
            _ = await apiViewModel.updateMyProfile()
            dismiss()
            toastViewModel.toastInit(message: ToastMessages().bioUpdated, padding: 32)
          }
        } label: {
          Text(CommonWords().done)
            .foregroundColor(.Info)
            .fontSystem(fontDesignSystem: .subtitle2)
        }
      }
    }
    .overlay {
      if toastViewModel.onFullScreenCover {
        ToastMessageView()
      }
      if alertViewModel.onFullScreenCover {
        AlertPopup()
      }
    }
    .onAppear {
      tabbarModel.tabbarOpacity = 0.0
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
