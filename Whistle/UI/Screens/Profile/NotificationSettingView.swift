//
//  NotificationSettingView.swift
//  Whistle
//
//  Created by ChoiYujin on 8/31/23.
//

import SwiftUI

// MARK: - NotificationSettingView

struct NotificationSettingView: View {
  @AppStorage("isAllOff") var isAllOff = false
  @Environment(\.dismiss) var dismiss
  @StateObject var apiViewModel = APIViewModel.shared

  var body: some View {
    VStack(spacing: 0) {
      Divider().frame(height: 1)
      Toggle("모두 일시 중단", isOn: $isAllOff)
        .frame(height: 64)
        .padding(.horizontal, 16)
      Divider().frame(height: 0.5).padding(.leading, 16)
      Toggle("게시글 휘슬 알림", isOn: $apiViewModel.notiSetting.whistleEnabled)
        .frame(height: 64)
        .padding(.horizontal, 16)
      Divider().frame(height: 0.5).padding(.leading, 16).foregroundColor(.Disable_Placeholder)
      Toggle("팔로워 알림", isOn: $apiViewModel.notiSetting.followEnabled)
        .frame(height: 64)
        .padding(.horizontal, 16)
      Divider().frame(height: 0.5).padding(.leading, 16).foregroundColor(.Disable_Placeholder)
      Toggle("Whistle에서 보내는 알림", isOn: $apiViewModel.notiSetting.infoEnabled)
        .frame(height: 64)
        .padding(.horizontal, 16)
      Divider().frame(height: 0.5).padding(.leading, 16).foregroundColor(.Disable_Placeholder)
      Toggle("광고 알림", isOn: $apiViewModel.notiSetting.adEnabled)
        .frame(height: 64)
        .padding(.horizontal, 16)
      Divider().frame(height: 0.5).padding(.leading, 16).foregroundColor(.Disable_Placeholder)
      Spacer()
    }
    .fontSystem(fontDesignSystem: .subtitle2)
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
          await apiViewModel.updateWhistleNoti(newSetting: false)
          await apiViewModel.updateFollowNoti(newSetting: false)
          await apiViewModel.updateServerNoti(newSetting: false)
          await apiViewModel.updateAdNoti(newSetting: false)
          await apiViewModel.requestNotiSetting()
        }
      }
    }
    .onChange(of: apiViewModel.notiSetting.whistleEnabled) { newValue in
      Task {
        await apiViewModel.updateWhistleNoti(newSetting: newValue)
        if newValue {
          isAllOff = false
        }
      }
    }
    .onChange(of: apiViewModel.notiSetting.followEnabled) { newValue in
      Task {
        await apiViewModel.updateFollowNoti(newSetting: newValue)
        if newValue {
          isAllOff = false
        }
      }
    }
    .onChange(of: apiViewModel.notiSetting.infoEnabled) { newValue in
      Task {
        await apiViewModel.updateServerNoti(newSetting: newValue)
        if newValue {
          isAllOff = false
        }
      }
    }
    .onChange(of: apiViewModel.notiSetting.adEnabled) { newValue in
      Task {
        await apiViewModel.updateAdNoti(newSetting: newValue)
        if newValue {
          isAllOff = false
        }
      }
    }
  }
}

extension NotificationSettingView { }
