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

  struct FeedTabItem: View {
    let systemName: String
    let tab: String
    @Binding var selectedTab: profileTabCase
    var body: some View {
      ZStack {
        VStack(spacing: 0) {
          Spacer()
          Rectangle()
            .foregroundColor(Color.Gray30_Dark)
            .frame(height: 1)
            .overlay {
              Capsule()
                .frame(height: 5)
                .foregroundColor(.white)
                .opacity(tab == selectedTab.rawValue ? 1 : 0)
            }
        }
        Image(systemName: systemName)
          .font(.system(size: 20))
          .foregroundColor(tab == selectedTab.rawValue ? Color.white : Color.LabelColor_DisablePlaceholder_Dark)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
    }
  }

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .overlay {
        FeedTabItem(systemName: systemName, tab: tab, selectedTab: $selectedTab)
      }
  }
}
