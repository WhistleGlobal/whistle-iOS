//
//  ProfileNotiView.swift
//  Whistle
//
//  Created by ChoiYujin on 8/31/23.
//

import SwiftUI

struct ProfileNotiView: View {
  @Environment(\.dismiss) var dismiss
  @EnvironmentObject var userViewModel: UserViewModel
  @Binding var isShowingBottomSheet: Bool
  @State var isOn = true

  var body: some View {
    List {
      Toggle("모두 일시 중단", isOn: $isOn)
      Toggle("게시글 휘슬 알림", isOn: $userViewModel.notiSetting.whistleEnabled)
      Toggle("팔로워 알림", isOn: $userViewModel.notiSetting.followEnabled)
      Toggle("Whistle에서 보내는 알림", isOn: $userViewModel.notiSetting.infoEnabled)
      Toggle("이메일 알림", isOn: $userViewModel.notiSetting.adEnabled)
    }
    .scrollDisabled(true)
    .foregroundColor(.LabelColor_Primary)
    .tint(.Primary_Default)
    .listStyle(.plain)
    .navigationBarBackButtonHidden()
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle("알림")
    .onAppear {
      isShowingBottomSheet = false
    }
    .task {
      userViewModel.requestNotiSetting()
    }
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button {
          dismiss()
        } label: {
          Image(systemName: "chevron.backward")
            .foregroundColor(.LabelColor_Primary)
        }
      }
    }
    .onChange(of: userViewModel.notiSetting.whistleEnabled) { newValue in
      userViewModel.updateSettingWhistle(newSetting: newValue)
    }
    .onChange(of: userViewModel.notiSetting.followEnabled) { newValue in
      userViewModel.updateSettingFollow(newSetting: newValue)
    }
    .onChange(of: userViewModel.notiSetting.infoEnabled) { newValue in
      userViewModel.updateSettingInfo(newSetting: newValue)
    }
    .onChange(of: userViewModel.notiSetting.adEnabled) { newValue in
      userViewModel.updateSettingAd(newSetting: newValue)
    }
  }
}
