//
//  ProfileNotiView.swift
//  Whistle
//
//  Created by ChoiYujin on 8/31/23.
//

import SwiftUI

struct ProfileNotiView: View {
  @Environment(\.dismiss) var dismiss
  @EnvironmentObject var apiViewModel: APIViewModel
  @AppStorage("isAllOff") var isAllOff = false

  var body: some View {
    List {
      Toggle("모두 일시 중단", isOn: $isAllOff)
      Toggle("게시글 휘슬 알림", isOn: $apiViewModel.notiSetting.whistleEnabled)
      Toggle("팔로워 알림", isOn: $apiViewModel.notiSetting.followEnabled)
      Toggle("Whistle에서 보내는 알림", isOn: $apiViewModel.notiSetting.infoEnabled)
      Toggle("이메일 알림", isOn: $apiViewModel.notiSetting.adEnabled)
    }
    .scrollDisabled(true)
    .foregroundColor(.LabelColor_Primary)
    .tint(.Primary_Default)
    .listStyle(.plain)
    .navigationBarBackButtonHidden()
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle("알림")
    .task {
      await apiViewModel.requestNotiSetting()
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
    .onChange(of: isAllOff) { newValue in
      if newValue {
        Task {
          await apiViewModel.updateSettingWhistle(newSetting: false)
          await apiViewModel.updateSettingFollow(newSetting: false)
          await apiViewModel.updateSettingInfo(newSetting: false)
          await apiViewModel.updateSettingAd(newSetting: false)
          await apiViewModel.requestNotiSetting()
        }
      }
    }
    .onChange(of: apiViewModel.notiSetting.whistleEnabled) { newValue in
      Task {
        await apiViewModel.updateSettingWhistle(newSetting: newValue)
        if newValue {
          isAllOff = false
        }
      }
    }
    .onChange(of: apiViewModel.notiSetting.followEnabled) { newValue in
      Task {
        await apiViewModel.updateSettingFollow(newSetting: newValue)
        if newValue {
          isAllOff = false
        }
      }
    }
    .onChange(of: apiViewModel.notiSetting.infoEnabled) { newValue in
      Task {
        await apiViewModel.updateSettingInfo(newSetting: newValue)
        if newValue {
          isAllOff = false
        }
      }
    }
    .onChange(of: apiViewModel.notiSetting.adEnabled) { newValue in
      Task {
        await apiViewModel.updateSettingAd(newSetting: newValue)
        if newValue {
          isAllOff = false
        }
      }
    }
  }
}
