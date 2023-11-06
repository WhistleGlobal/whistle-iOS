//
//  MemberFollowListView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/21/23.
//

import Kingfisher
import SwiftUI

// MARK: - MemberFollowListView

struct MemberFollowListView: View {
  // MARK: Internal

  @Environment(\.dismiss) var dismiss
  @StateObject var apiViewModel = APIViewModel.shared
  @State var newId = UUID()
  @State var tabStatus: profileTabStatus = .follower
  @State var showOtherProfile = false
  @State var showUserProfile = false
  @State var memberFollowing: [MemberFollowingData] = []
  @State var memberFollower: [FollowerData] = []
  let userId: Int

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
      if tabStatus == .follower {
        if apiViewModel.memberFollow.followerCount == 0 {
          Spacer()
          NoFollowerLabel(tabStatus: $tabStatus, profileType: .member)
        } else {
          FollowerList(filteredFollower: filteredFollower)
            .onReceive(apiViewModel.publisher) { id in
              newId = id
            }
            .id(newId)
        }
      } else {
        if apiViewModel.memberFollow.followingCount == 0 {
          Spacer()
          NoFollowerLabel(tabStatus: $tabStatus, profileType: .member)
        } else {
          MemberFollowingList(filteredFollowing: filteredFollowing)
            .onReceive(apiViewModel.publisher) { id in
              newId = id
            }
            .id(newId)
        }
      }
      Spacer()
    }
    .navigationBarBackButtonHidden()
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button {
          dismiss()
        } label: {
          Image(systemName: "chevron.backward")
            .foregroundColor(.LabelColor_Primary)
        }
      }
      ToolbarItem(placement: .principal) {
        Text("\(apiViewModel.memberProfile.userName)")
          .fontSystem(fontDesignSystem: .subtitle2)
      }
    }
    .task {
      await apiViewModel.requestMemberFollow(userID: userId)
      memberFollower = apiViewModel.memberFollow.followerList
      memberFollowing = apiViewModel.memberFollow.followingList
    }
  }
}

extension MemberFollowListView {
  var filteredFollower: [FollowerData] {
    memberFollower.filter { !BlockList.shared.userIds.contains($0.followerId) }
  }

  var filteredFollowing: [MemberFollowingData] {
    memberFollowing.filter { !BlockList.shared.userIds.contains($0.followingId) }
  }
}
