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
      .frame(height: 48)
      if tabStatus == .follower {
        if apiViewModel.memberFollow.followerCount == 0 {
          Spacer()
          followEmptyView()
        } else {
          memberFollowerList()
            .onReceive(apiViewModel.publisher) { id in
              newId = id
            }
            .id(newId)
        }
      } else {
        if apiViewModel.memberFollow.followingCount == 0 {
          Spacer()
          followEmptyView()
        } else {
          memberFollowingList()
            .onReceive(apiViewModel.publisher) { id in
              newId = id
            }
            .id(newId)
        }
      }

      Spacer()
    }
    .padding(.horizontal, 16)
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
          .fontSystem(fontDesignSystem: .subtitle2_KO)
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
  @ViewBuilder
  func personRow(
    isFollowed: Binding<Bool>,
    userName: String,
    description _: String,
    profileImage: String,
    userId: Int)
    -> some View
  {
    HStack(spacing: 0) {
      profileImageView(url: profileImage, size: 48)
      VStack(spacing: 0) {
        Text(userName)
          .fontSystem(fontDesignSystem: .subtitle2_KO)
          .foregroundColor(.LabelColor_Primary)
          .frame(maxWidth: .infinity, alignment: .leading)
//        Text(description)
//          .fontSystem(fontDesignSystem: .body2_KO)
//          .foregroundColor(.LabelColor_Secondary)
//          .frame(maxWidth: .infinity, alignment: .leading)
      }
      .padding(.leading, 16)
      if userName != apiViewModel.myProfile.userName {
        Button("") {
          Task {
            if isFollowed.wrappedValue {
              await apiViewModel.followAction(userID: userId, method: .delete)
              apiViewModel.mainFeed = apiViewModel.mainFeed.map { content in
                let updatedContent = content
                if content.userId == userId {
                  updatedContent.isFollowed.toggle()
                }
                return updatedContent
              }
            } else {
              await apiViewModel.followAction(userID: userId, method: .post)
              apiViewModel.mainFeed = apiViewModel.mainFeed.map { content in
                let updatedContent = content
                if content.userId == userId {
                  updatedContent.isFollowed.toggle()
                }
                return updatedContent
              }
            }
            isFollowed.wrappedValue.toggle()
            apiViewModel.publisherSend()
          }
        }
        .buttonStyle(FollowButtonStyle(isFollowed: isFollowed))
      }
      Spacer()
    }
    .frame(height: 72)
    .frame(maxWidth: .infinity)
  }

  @ViewBuilder
  func followEmptyView() -> some View {
    Image(systemName: "person.fill")
      .resizable()
      .scaledToFit()
      .frame(width: 48, height: 48)
      .foregroundColor(.LabelColor_Primary)
      .padding(.bottom, 32)
    Text(
      tabStatus == .follower ? "아직 회원님을 팔로우하는 사람이 없습니다" : "아직 회원님이 팔로우하는 사람이 없습니다")
      .fontSystem(fontDesignSystem: .body1_KO)
      .foregroundColor(.LabelColor_Secondary)
      .padding(.bottom, 64)
  }

  @ViewBuilder
  func memberFollowerList() -> some View {
    ScrollView {
      ForEach(filteredFollower, id: \.userName) { follower in
        NavigationLink {
          MemberProfileView(userId: follower.followerId)
            .environmentObject(apiViewModel)
            .id(UUID())
        } label: {
          personRow(
            isFollowed: Binding(get: {
              follower.isFollowed
            }, set: { newValue in
              follower.isFollowed = newValue
            }),
            userName: follower.userName,
            description: follower.userName,
            profileImage: follower.profileImg ?? "",
            userId: follower.followerId)
        }
        .id(UUID())
      }
    }
    .scrollIndicators(.hidden)
  }

  @ViewBuilder
  func memberFollowingList() -> some View {
    ScrollView {
      ForEach(filteredFollowing, id: \.userName) { following in
        NavigationLink {
          MemberProfileView(userId: following.followingId)
            .environmentObject(apiViewModel)
            .id(UUID())
        } label: {
          personRow(
            isFollowed: Binding(get: {
              following.isFollowed
            }, set: { newValue in
              following.isFollowed = newValue
            }),
            userName: following.userName,
            description: following.userName,
            profileImage: following.profileImg ?? "",
            userId: following.followingId)
        }
        .id(UUID())
      }
    }
    .scrollIndicators(.hidden)
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
