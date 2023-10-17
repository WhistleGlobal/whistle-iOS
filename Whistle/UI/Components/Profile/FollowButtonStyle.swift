//
//  FollowButtonStyle.swift
//  Whistle
//
//  Created by ChoiYujin on 9/2/23.
//

import SwiftUI

// MARK: - FollowButtonStyle

struct FollowButtonStyle: ButtonStyle {

  struct FollowButton: View {

    let configuration: ButtonStyle.Configuration
    @Environment(\.isEnabled) private var isEnabled: Bool
    @Binding var isFollowed: Bool

    var body: some View {
      Text(isFollowed ? "팔로잉" : "팔로우")
        .frame(width: 85, height: 36)
        .foregroundColor(isFollowed ? .Gray30_Dark : .LabelColor_Primary_Dark)
        .fontSystem(fontDesignSystem: .subtitle2_KO)
        .background(
          Capsule()
            .frame(width: 85, height: 36)
            .foregroundColor(followButtonColor()))
    }

    func followButtonColor() -> Color {
      switch (isFollowed, isEnabled, configuration.isPressed) {
      // Follow/Pressed
      case (false, true, true):
        return .Blue_Pressed
      // Follow/Not pressed
      case (false, true, false):
        return .Blue_Default
      // Follow/Disable
      case (false, false, _):
        return .Blue_Disabled

      // Following/Pressed
      case (true, true, true):
        return .Blue_Pressed
      // Following/Not pressed
      case (true, true, false):
        return .Blue_Disabled
      // Following/Disable
      case (true, false, _):
        return .Blue_Disabled
      }
    }
  }

  @Binding var isFollowed: Bool

  func makeBody(configuration: Configuration) -> some View {
    FollowButton(configuration: configuration, isFollowed: $isFollowed)
  }
}
