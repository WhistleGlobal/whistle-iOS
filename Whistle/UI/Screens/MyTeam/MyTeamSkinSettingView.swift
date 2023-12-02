//
//  MyTeamSkinSettingView.swift
//  Whistle
//
//  Created by ChoiYujin on 11/15/23.
//

import SwiftUI

struct MyTeamSkinSettingView: View {

  @Binding var isMyTeamLabelOn: Bool
  @Binding var isMyTeamBackgroundOn: Bool

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
    .toolbar {
      ToolbarItem(placement: .principal) {
        Text(ProfileEditWords().myTeamSkinSelect)
          .foregroundStyle(Color.labelColorPrimary)
          .font(.headline)
      }
    }
    .toolbarRole(.editor)
  }
}
