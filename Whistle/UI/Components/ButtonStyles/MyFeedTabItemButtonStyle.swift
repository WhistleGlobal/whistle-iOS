//
//  ProfileTabItem.swift
//  Whistle
//
//  Created by ChoiYujin on 9/1/23.
//

import SwiftUI

struct MyFeedTabItemButtonStyle: ButtonStyle {
  // MARK: Lifecycle

  init(systemName: String, tab: String, selectedTab: Binding<profileTabCase>) {
    self.systemName = systemName
    self.tab = tab
    _selectedTab = selectedTab
  }

  // MARK: Internal

  let systemName: String
  let tab: String
  @Binding var selectedTab: profileTabCase

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .overlay {
        Image(systemName: systemName)
          .resizable()
          .scaledToFit()
          .frame(width: 20, height: 20)
      }
      .overlay(alignment: .bottom) {
        Rectangle()
          .foregroundColor(Color.Gray30_Dark)
          .frame(height: 1)
      }
      .overlay(alignment: .bottom) {
        Capsule()
          .frame(width: (UIScreen.width - 32) / 2, height: 5)
          .foregroundColor(.white)
          .opacity(tab == selectedTab.rawValue ? 1 : 0)
          .offset(y: 2.5)
      }
      .foregroundColor(tab == selectedTab.rawValue ? .white : Color.Disable_Placeholder_Dark)
      .background(.clear)
  }
}
