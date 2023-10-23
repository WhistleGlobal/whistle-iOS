//
//  ProfileEditButtonStyle.swift
//  Whistle
//
//  Created by ChoiYujin on 9/2/23.
//

import SwiftUI

struct ProfileEditButtonStyle: ButtonStyle {
  struct ProfileEditButton: View {
    // MARK: Internal

    let configuration: ButtonStyle.Configuration

    var body: some View {
      Capsule()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundColor(followButtonColor())
    }

    func followButtonColor() -> Color {
      switch (isEnabled, configuration.isPressed) {
      // Pressed
      case (true, true):
        .Gray_Pressed
      // Not pressed
      case (true, false):
        .Gray_Default
      // Disable
      case (false, _):
        .Gray_Disabled
      }
    }

    // MARK: Private

    @Environment(\.isEnabled) private var isEnabled: Bool
  }

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .background(ProfileEditButton(configuration: configuration))
  }
}
