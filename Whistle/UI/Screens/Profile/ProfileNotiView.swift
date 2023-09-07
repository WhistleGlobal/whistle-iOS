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
      log(newValue)
      userViewModel.updateSettingWhistle(newSetting: newValue)
    }
    .onChange(of: userViewModel.notiSetting.followEnabled) { _ in
    }
    .onChange(of: userViewModel.notiSetting.infoEnabled) { _ in
    }
    .onChange(of: userViewModel.notiSetting.adEnabled) { _ in
    }
  }
}
