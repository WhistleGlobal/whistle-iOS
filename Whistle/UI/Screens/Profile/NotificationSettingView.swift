//
//  NotificationSettingView.swift
//  Whistle
//
//  Created by ChoiYujin on 8/31/23.
//

import SwiftUI

// MARK: - NotificationSettingView

struct NotificationSettingView: View {
  @Environment(\.dismiss) var dismiss
  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject private var alertViewModel = AlertViewModel.shared
  @State private var isLoaded = false

  var body: some View {
    VStack(spacing: 0) {
      Toggle("게시글 휘슬 알림", isOn: $apiViewModel.notiSetting.whistleEnabled)
        .frame(height: 64)
        .padding(.horizontal, 16)
      Divider().frame(height: 0.5).padding(.leading, 16).foregroundColor(.labelColorDisablePlaceholder)
      Toggle("팔로워 알림", isOn: $apiViewModel.notiSetting.followEnabled)
        .frame(height: 64)
        .padding(.horizontal, 16)
      Divider().frame(height: 0.5).padding(.leading, 16).foregroundColor(.labelColorDisablePlaceholder)
      Toggle("Whistle에서 보내는 알림", isOn: $apiViewModel.notiSetting.infoEnabled)
        .frame(height: 64)
        .padding(.horizontal, 16)
      Color.elevatedBackground.frame(height: 16)
      Toggle("광고성 정보 알림", isOn: $apiViewModel.notiSetting.adEnabled)
        .frame(height: 64)
        .padding(.horizontal, 16)
      Spacer()
    }
    .toolbarBackground(Color.backgroundDefault, for: .navigationBar)
    .toolbarBackground(.visible, for: .navigationBar)
    .fontSystem(fontDesignSystem: .subtitle2)
    .ignoresSafeArea(edges: .bottom)
    .foregroundColor(.labelColorPrimary)
    .tint(.Primary_Default)
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle("알림 설정")
    .toolbarRole(.editor)
    .task {
      await apiViewModel.requestNotiSetting()
      isLoaded = true
    }
    .overlay {
      if alertViewModel.onFullScreenCover {
        AlertPopup()
      }
    }
    .onChange(of: apiViewModel.notiSetting.whistleEnabled) { newValue in
      Task {
        await apiViewModel.updateWhistleNoti(newSetting: newValue)
      }
    }
    .onChange(of: apiViewModel.notiSetting.followEnabled) { newValue in
      Task {
        await apiViewModel.updateFollowNoti(newSetting: newValue)
      }
    }
    .onChange(of: apiViewModel.notiSetting.infoEnabled) { newValue in
      Task {
        await apiViewModel.updateServerNoti(newSetting: newValue)
      }
    }
    .onChange(of: apiViewModel.notiSetting.adEnabled) { newValue in
      if !isLoaded {
        isLoaded = true
        return
      }
      alertViewModel.submitAlert(
        title: adMarketingTitle(isAllow: newValue),
        content: "\(adMarketingText(isAllow: newValue))",
        submitText:CommonWords().confirm)
      Task {
        await apiViewModel.updateAdNoti(newSetting: newValue)
      }
    }
  }
}

extension NotificationSettingView {

  func adMarketingText(isAllow: Bool) -> String {
    let userLocale = Locale.current
    let languageCode = userLocale.language.languageCode?.identifier ?? "KR"
    let dateFormatter = DateFormatter()

    switch languageCode {
    case "KR":
      dateFormatter.dateFormat = "yyyy년 M월 d일 hh시"
    case "en":
      dateFormatter.dateFormat = "yyyy-MM-dd-hh"
    default:
      dateFormatter.dateFormat = "yyyy-MM-dd-hh"
    }
    let currentDate = Date()
    let formattedDate = dateFormatter.string(from: currentDate)
    switch languageCode {
    case "KR":
      return """
        전송자 : Whistle
        수신\(isAllow ? "동의" : "거부") 일시: \(formattedDate)
        처리내용: 수신\(isAllow ? "동의" : "거부") 처리 완료
        * 내 프로필 > 알림 설정에서 변경 가능
        """
    case "en":
      return
        """
        Sender: Whistle
        Consent Date: \(formattedDate)
        Action Taken: Consent \(isAllow ? "granted" : "denied") successfully processed
        * You can change this in My Profile > Notification Settings
        """
    default:
      return """
        전송자 : Whistle
        수신\(isAllow ? "동의" : "거부") 일시: \(formattedDate)
        처리내용: 수신\(isAllow ? "동의" : "거부") 처리 완료
        * 내 프로필 > 알림 설정에서 변경 가능
        """
    }
  }

  func adMarketingTitle(isAllow: Bool) -> LocalizedStringKey {
    isAllow ? NotificationWords().agreedTitle : NotificationWords().disagreedTitle
  }
}
