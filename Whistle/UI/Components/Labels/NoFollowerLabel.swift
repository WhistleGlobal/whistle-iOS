//
//  NoFollowerLabel.swift
//  Whistle
//
//  Created by 박상원 on 11/6/23.
//

import SwiftUI

// MARK: - NoFollowerLabel

struct NoFollowerLabel: View {
  @Binding var tabStatus: profileTabStatus
  var profileType: ProfileType

  var body: some View {
    Image(systemName: "person.fill")
      .resizable()
      .scaledToFit()
      .frame(width: 48, height: 48)
      .foregroundColor(.labelColorPrimary)
      .padding(.bottom, 32)
    switch profileType {
    case .my:
      Text(
        tabStatus == .follower ? "아직 회원님을 팔로우하는 사람이 없습니다" : "아직 회원님이 팔로우하는 사람이 없습니다")
        .fontSystem(fontDesignSystem: .body1)
        .foregroundColor(.labelColorSecondary)
        .padding(.bottom, 64)
    case .member:
      Text(
        tabStatus == .follower ? "해당 사용자를 팔로우하는 사람이 없습니다" : "해당 사용자가 팔로우하는 사람이 없습니다")
        .fontSystem(fontDesignSystem: .body1)
        .foregroundColor(.labelColorSecondary)
        .padding(.bottom, 64)
    }
  }
}
