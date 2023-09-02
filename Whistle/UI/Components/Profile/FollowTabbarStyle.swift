//
//  FollowTabbarStyle.swift
//  Whistle
//
//  Created by ChoiYujin on 9/2/23.
//

import SwiftUI

// MARK: - FollowTabbarStyle

struct FollowTabbarStyle: ButtonStyle {

  // MARK: Lifecycle


  init(systemName: String, tab: String, selectedTab: Binding<FollowView.profileTabStatus>) {
    self.systemName = systemName
    self.tab = tab
    _selectedTab = selectedTab
  }

  // MARK: Internal


  struct FollowTabItem: View {

    let systemName: String
    let tab: String
    @Binding var selectedTab: FollowView.profileTabStatus

    var body: some View {
      Text("")
    }
  }


  let systemName: String
  let tab: String
  @Binding var selectedTab: FollowView.profileTabStatus


  func makeBody(configuration: Configuration) -> some View {
    configuration.label
  }
}

// struct ProfileTabItem: ButtonStyle {
//
//  // MARK: Lifecycle
//
//  init(systemName: String, tab: String, selectedTab: Binding<ProfileView.profileTabCase>) {
//    self.systemName = systemName
//    self.tab = tab
//    _selectedTab = selectedTab
//  }
//
//  // MARK: Internal
//
//  let systemName: String
//  let tab: String
//  @Binding var selectedTab: ProfileView.profileTabCase
//
//  func makeBody(configuration: Configuration) -> some View {
//    configuration.label
//      .frame(maxWidth: .infinity, maxHeight: .infinity)
//      .overlay {
//        Image(systemName: systemName)
//          .resizable()
//          .scaledToFit()
//          .frame(width: 24, height: 24)
//      }
//      .overlay(alignment: .bottom) {
//        Rectangle()
//          .foregroundColor(Color.Gray30_Dark)
//          .frame(height: 1)
//      }
//      .overlay(alignment: .bottom) {
//        Capsule()
//          .frame(width: (UIScreen.width - 32) / 2, height: 5)
//          .foregroundColor(.White)
//          .opacity(tab == selectedTab.rawValue ? 1 : 0)
//          .offset(y: 2.5)
//      }
//      .foregroundColor(tab == selectedTab.rawValue ? Color.White : Color.Gray30_Dark)
//      .background(.clear)
//  }
// }
//
