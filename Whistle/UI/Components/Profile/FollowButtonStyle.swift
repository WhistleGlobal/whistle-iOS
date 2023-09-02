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
    @Binding var isFollow: Bool

    var body: some View {
      Text(isFollow ? "Follow" : "Following")
        .frame(width: 112, height: 36)
        .foregroundColor(.LabelColor_Primary_Dark)
        .background(
          Capsule()
            .frame(width: 112, height: 36)
            .foregroundColor(followButtonColor()))
    }

    func followButtonColor() -> Color {
      switch (isFollow, isEnabled, configuration.isPressed) {
      // Follow
      case (true, true, true):
        return .blue.opacity(0.5)
      // Follow/Not pressed
      case (true, true, false):
        return .red
      // Follow/Disable
      case (true, false, _):
        return .blue.opacity(0.1)
      // Following
      case (false, true, true):
        return .gray.opacity(0.7)
      // Following/Not pressed
      case (false, true, false):
        return .gray
      // Following/Disable
      case (false, false, _):
        return .green.opacity(0.2)
      }
    }
  }

  @State var isFollow: Bool


  func makeBody(configuration: Configuration) -> some View {
    FollowButton(configuration: configuration, isFollow: $isFollow)
  }
}
