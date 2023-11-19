//
//  MyTeamSkinSettingView.swift
//  Whistle
//
//  Created by ChoiYujin on 11/15/23.
//

import SwiftUI

struct MyTeamSkinSettingView: View {

  @AppStorage("isMyTeamLabelOn") var isMyTeamLabelOn = false
  @AppStorage("isMyTeamBackgroundOn") var isMyTeamBackgroundOn = false

  var body: some View {
    VStack(spacing: 0) {
      Divider().foregroundColor(.labelColorDisablePlaceholder)
      Toggle(ProfileEditWords().showMyTeamFlag, isOn: $isMyTeamLabelOn)
        .frame(height: 64)
        .padding(.horizontal, 16)
      Divider().frame(height: 0.5).padding(.leading, 16).foregroundColor(.labelColorDisablePlaceholder)
      Toggle(ProfileEditWords().showMyTeamProfileBackground, isOn: $isMyTeamBackgroundOn)
        .frame(height: 64)
        .padding(.horizontal, 16)
      Divider().frame(height: 0.5).padding(.leading, 16).foregroundColor(.labelColorDisablePlaceholder)
      Spacer()
    }
    .tint(.Primary_Default)
    .fontSystem(fontDesignSystem: .subtitle2)
    .foregroundColor(.labelColorPrimary)
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle(ProfileEditWords().myTeamSkinSelect)
    .toolbarRole(.editor)
  }
}

#Preview {
  MyTeamSkinSettingView()
}
