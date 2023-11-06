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
      Text(isFollowed ? CommonWords().following : CommonWords().follow)
        .padding(.horizontal, 20)
        .padding(.vertical, 4)
        .foregroundColor(isFollowed ? .Disable_Placeholder_Dark : .LabelColor_Primary_Dark)
        .fontSystem(fontDesignSystem: .subtitle2)
        .background(
          Capsule()
            .foregroundColor(followButtonColor()))
    }

    func followButtonColor() -> Color {
      switch (isFollowed, isEnabled, configuration.isPressed) {
      // Follow/Pressed
      case (false, true, true):
        .Blue_Pressed
      // Follow/Not pressed
      case (false, true, false):
        .Blue_Default
      // Follow/Disable
      case (false, false, _):
        .Blue_Disabled

      // Following/Pressed
      case (true, true, true):
        .Blue_Pressed
      // Following/Not pressed
      case (true, true, false):
        .Blue_Disabled
      // Following/Disable
      case (true, false, _):
        .Blue_Disabled
      }
    }
  }

  @Binding var isFollowed: Bool

  func makeBody(configuration: Configuration) -> some View {
    FollowButton(configuration: configuration, isFollowed: $isFollowed)
  }
}
