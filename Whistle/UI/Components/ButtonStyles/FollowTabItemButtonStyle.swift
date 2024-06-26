//
//  FollowTabbarStyle.swift
//  Whistle
//
//  Created by ChoiYujin on 9/2/23.
//

import SwiftUI

// MARK: - FollowTabbarStyle

struct FollowTabItemButtonStyle: ButtonStyle {
  // MARK: Lifecycle

  init(followNum: Int, tab: String, selectedTab: Binding<profileTabStatus>) {
    self.followNum = followNum
    self.tab = tab
    _selectedTab = selectedTab
  }

  // MARK: Internal

  struct FollowTabItem: View {
    let followNum: Int
    let tab: String
    @Binding var selectedTab: profileTabStatus

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
                .foregroundColor(.labelColorPrimary)
                .opacity(tab == selectedTab.rawValue ? 1 : 0)
            }
        }
        Text(tab == profileTabStatus.follower.rawValue ? "\(followNum) 팔로워" : "\(followNum) 팔로잉")
          .fontSystem(fontDesignSystem: .subtitle2)
          .fontWeight(.semibold)
          .foregroundColor(tab == selectedTab.rawValue ? Color.labelColorPrimary : Color.labelColorDisablePlaceholder)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
  }

  let followNum: Int
  let tab: String
  @Binding var selectedTab: profileTabStatus

  func makeBody(configuration _: Configuration) -> some View {
    FollowTabItem(followNum: followNum, tab: tab, selectedTab: $selectedTab)
  }
}
