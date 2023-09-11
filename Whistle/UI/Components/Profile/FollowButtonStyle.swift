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
      Text(isFollowed ? "following" : "follow")
        .frame(width: 112, height: 36)
        .foregroundColor(.LabelColor_Primary_Dark)
        .background(
          Capsule()
            .frame(width: 112, height: 36)
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
        return .Gray_Pressed
      // Following/Not pressed
      case (true, true, false):
        return .Gray_Default
      // Following/Disable
      case (true, false, _):
        return .Gray_Disabled
      }
    }
  }

  @Binding var isFollowed: Bool

  func makeBody(configuration: Configuration) -> some View {
    FollowButton(configuration: configuration, isFollowed: $isFollowed)
  }
}
