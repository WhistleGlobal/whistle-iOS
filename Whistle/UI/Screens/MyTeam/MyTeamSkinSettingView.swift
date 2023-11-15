//
//  MyTeamSkinSettingView.swift
//  Whistle
//
//  Created by ChoiYujin on 11/15/23.
//

import SwiftUI

struct MyTeamSkinSettingView: View {

  @AppStorage("isMyTeamFlagOn") var isMyTeamFlagOn = false
  @AppStorage("isMyTeamBackgroundOn") var isMyTeamBackgroundOn = false

  var body: some View {
    VStack(spacing: 0) {
      Divider().foregroundColor(.Disable_Placeholder)
      Toggle(ProfileEditWords().showMyTeamFlag, isOn: $isMyTeamFlagOn)
        .frame(height: 64)
        .padding(.horizontal, 16)
      Divider().frame(height: 0.5).padding(.leading, 16).foregroundColor(.Disable_Placeholder)
      Toggle(ProfileEditWords().showMyTeamProfileBackground, isOn: $isMyTeamBackgroundOn)
        .frame(height: 64)
        .padding(.horizontal, 16)
      Divider().frame(height: 0.5).padding(.leading, 16).foregroundColor(.Disable_Placeholder)
      Spacer()
    }
    .tint(.Primary_Default)
    .fontSystem(fontDesignSystem: .subtitle2)
    .foregroundColor(.LabelColor_Primary)
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle(ProfileEditWords().myTeamSkinSelect)
    .toolbarRole(.editor)
  }
}

#Preview {
  MyTeamSkinSettingView()
}
