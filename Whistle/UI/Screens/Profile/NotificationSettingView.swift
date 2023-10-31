//
//  NotificationSettingView.swift
//  Whistle
//
//  Created by ChoiYujin on 8/31/23.
//

import SwiftUI

struct NotificationSettingView: View {
  @AppStorage("isAllOff") var isAllOff = false
  @Environment(\.dismiss) var dismiss
  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject var alertViewModel = AlertViewModel.shared
  @State var showAlert = false
  let persistenceController = PersistenceController.shared
  let center = UNUserNotificationCenter.current()

  var body: some View {
    List {
      Toggle("모두 일시 중단", isOn: $isAllOff)
        .listRowSeparator(.hidden)
      Toggle("게시글 휘슬 알림", isOn: $apiViewModel.notiSetting.whistleEnabled)
        .listRowSeparator(.hidden)
      Toggle("팔로워 알림", isOn: $apiViewModel.notiSetting.followEnabled)
        .listRowSeparator(.hidden)
      Toggle("Whistle에서 보내는 알림", isOn: $apiViewModel.notiSetting.infoEnabled)
        .listRowSeparator(.hidden)
      Toggle("광고 알림", isOn: $apiViewModel.notiSetting.adEnabled)
        .listRowSeparator(.hidden)
    }
    .fontSystem(fontDesignSystem: .subtitle2_KO)
    .listRowSpacing(16)
    .scrollDisabled(true)
    .foregroundColor(.LabelColor_Primary)
    .tint(.Primary_Default)
    .listStyle(.plain)
    .navigationBarBackButtonHidden()
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle("알림")
    .overlay {
      if !alertViewModel.onFullScreenCover {
        AlertPopup()
      }
    }
    .onAppear {
      center.requestAuthorization(options: [.sound , .alert , .badge]) { granted, error in
        if let error {
          WhistleLogger.logger.error("\(error)")
          return
        }
        if !granted {
          alertViewModel.linearAlert(
            isRed: false,
            title: "휘슬 앱 알림이 허용되지 않았습니다.\n설정에서 알림을 켜시겠습니까?",
            cancelText: "취소",
            destructiveText: "설정으로 가기", cancelAction: {
              dismiss()
            }) {
              dismiss()
              guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
              if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
              }
            }
        } else {
          Task {
            await apiViewModel.requestNotiSetting()
          }
        }
      }
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
