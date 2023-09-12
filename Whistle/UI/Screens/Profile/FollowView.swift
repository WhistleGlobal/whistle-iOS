//
//  FollowView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/2/23.
//

import Kingfisher
import SwiftUI

// MARK: - FollowView

struct FollowView: View {

  // MARK: Public

  public enum profileTabStatus: String {
    case follower
    case following
  }

  // MARK: Internal

  @Environment(\.dismiss) var dismiss
  @EnvironmentObject var apiViewModel: APIViewModel
  @State var tabStatus: profileTabStatus = .follower
  @State var showOtherProfile = false
  @State var selectedId: Int?
  @State var userId: Int?

  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        Button("") {
          tabStatus = .follower
        }
        .buttonStyle(
          FollowTabbarStyle(
            followNum: userId == nil ? apiViewModel.myFollow.followerCount : apiViewModel.userFollow.followerCount,
            tab: profileTabStatus.follower.rawValue,
            selectedTab: $tabStatus))
        Button("") {
          tabStatus = .following
        }
        .buttonStyle(
          FollowTabbarStyle(
            followNum: userId == nil
              ? apiViewModel.myFollow.followingCount
              : apiViewModel.userFollow.followingCount,
            tab: profileTabStatus.following.rawValue,
            selectedTab: $tabStatus))
      }
      .frame(height: 48)
      // FIXME: - 코드 리팩 필요
      if tabStatus == .follower {
        if apiViewModel.myFollow.followerCount == 0 {
          Spacer()
          followEmptyView()
        } else {
          if let userId {
            userFollowerList()
          } else {
            myFollowerList()
          }
        }
      } else {
        if apiViewModel.myFollow.followingCount == 0 {
          Spacer()
          followEmptyView()
        } else {
          if let userId {
            userFollowingList()
          } else {
            myFollowingList()
          }
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
        Text("Whistle")
          .fontSystem(fontDesignSystem: .subtitle2_KO)
      }
    }
    .task {
      if let userId {
        await apiViewModel.requestUserFollow(userId: userId)
      } else {
        await apiViewModel.requestMyFollow()
      }
    }
  }
}

extension FollowView {
  @ViewBuilder
  func personRow(
    isFollowed: Binding<Bool>,
    userName: String,
    description: String,
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
        Text(description)
          .fontSystem(fontDesignSystem: .body2_KO)
          .foregroundColor(.LabelColor_Secondary)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
      .padding(.leading, 16)
      Button("") {
        Task {
          log("Button pressed")
          log(userId)
          log(isFollowed.wrappedValue)
          if isFollowed.wrappedValue {
            await apiViewModel.unfollowUser(userId: userId)
          } else {
            await apiViewModel.followUser(userId: userId)
          }
        }
      }
      .buttonStyle(FollowButtonStyle(isFollowed: isFollowed))
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
    Text("아직 회원님을 팔로우하는 사람이 없습니다")
      .fontSystem(fontDesignSystem: .body1_KO)
      .foregroundColor(.LabelColor_Secondary)
      .padding(.bottom, 64)
  }

  @ViewBuilder
  func myFollowerList() -> some View {
    ForEach(apiViewModel.myFollow.followerList, id: \.userName) { follower in
      NavigationLink {
        UserProfileView(userId: follower.followerId)
          .environmentObject(apiViewModel)
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
    }
  }

  @ViewBuilder
  func myFollowingList() -> some View {
    ForEach(apiViewModel.myFollow.followingList, id: \.userName) { following in
      NavigationLink {
        UserProfileView(userId: following.followingId)
          .environmentObject(apiViewModel)
      } label: {
        personRow(
          isFollowed: .constant(true),
          userName: following.userName,
          description: following.userName,
          profileImage: following.profileImg ?? "",
          userId: following.followingId)
      }
    }
  }

  @ViewBuilder
  func userFollowerList() -> some View {
    ForEach(apiViewModel.userFollow.followerList, id: \.userName) { follower in
      NavigationLink {
        UserProfileView(userId: follower.followerId)
          .environmentObject(apiViewModel)
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
    }
  }

  @ViewBuilder
  func userFollowingList() -> some View {
    ForEach(apiViewModel.userFollow.followingList, id: \.userName) { following in
      NavigationLink {
        UserProfileView(userId: following.followingId)
          .environmentObject(apiViewModel)
      } label: {
        personRow(
          isFollowed: .constant(true),
          userName: following.userName,
          description: following.userName,
          profileImage: following.profileImg ?? "",
          userId: following.followingId)
      }
    }
  }
}
