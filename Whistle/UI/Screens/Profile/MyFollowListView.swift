//
//  MyFollowListView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/2/23.
//

import Kingfisher
import SwiftUI

// MARK: - profileTabStatus

enum profileTabStatus: String {
  case follower
  case following
}

// MARK: - MyFollowListView

struct MyFollowListView: View {
  // MARK: Internal

  @Environment(\.dismiss) var dismiss
  @StateObject var apiViewModel = APIViewModel.shared
  @State var newId = UUID()
  @State var tabStatus: profileTabStatus = .follower
  @State var showOtherProfile = false
  @State var showUserProfile = false

  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        Button("") {
          tabStatus = .follower
        }
        .buttonStyle(
          FollowTabItemButtonStyle(
            followNum: filteredFollower.count,
            tab: profileTabStatus.follower.rawValue,
            selectedTab: $tabStatus))
        Button("") {
          tabStatus = .following
        }
        .buttonStyle(
          FollowTabItemButtonStyle(
            followNum: filteredFollowing.count,
            tab: profileTabStatus.following.rawValue,
            selectedTab: $tabStatus))
      }
      .padding(.horizontal, 16)
      .frame(height: 48)
      // FIXME: - 코드 리팩 필요
      if tabStatus == .follower {
        if apiViewModel.myFollow.followerCount == 0 {
          Spacer()
          NoFollowerLabel(tabStatus: $tabStatus, profileType: .my)
        } else {
          FollowerList(filteredFollower: filteredFollower)
            .onReceive(apiViewModel.publisher) { id in
              newId = id
            }
            .id(newId)
        }
      } else {
        if apiViewModel.myFollow.followingCount == 0 {
          Spacer()
          NoFollowerLabel(tabStatus: $tabStatus, profileType: .my)
        } else {
          MyFollowingList(filteredFollowing: filteredFollowing)
            .onReceive(apiViewModel.publisher) { id in
              newId = id
            }
            .id(newId)
        }
      }
      Spacer()
    }
    .background(.backgroundDefault)
    .toolbarBackground(.hidden, for: .navigationBar)
    .toolbarRole(.editor)
    .navigationTitle("\(apiViewModel.myProfile.userName)")
    .navigationBarTitleDisplayMode(.inline)
    .task {
      await apiViewModel.requestMyFollow()
    }
  }
}

extension MyFollowListView {
  var filteredFollower: [FollowerData] {
    apiViewModel.myFollow.followerList.filter { !BlockList.shared.userIds.contains($0.followerId) }
  }

  var filteredFollowing: [FollowingData] {
    apiViewModel.myFollow.followingList.filter { !BlockList.shared.userIds.contains($0.followingId) }
  }
}
