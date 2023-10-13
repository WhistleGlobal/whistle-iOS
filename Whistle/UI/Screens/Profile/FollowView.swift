//
//  FollowView.swift
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

// MARK: - FollowView

struct FollowView: View {

  // MARK: Internal

  @Environment(\.dismiss) var dismiss
  @EnvironmentObject var apiViewModel: APIViewModel
  @EnvironmentObject var tabbarModel: TabbarModel
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
          FollowTabbarStyle(
            followNum: apiViewModel.myFollow.followerCount,
            tab: profileTabStatus.follower.rawValue,
            selectedTab: $tabStatus))
        Button("") {
          tabStatus = .following
        }
        .buttonStyle(
          FollowTabbarStyle(
            followNum: apiViewModel.myFollow.followingCount,
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
          myFollowerList()
            .onReceive(apiViewModel.publisher) { id in
              newId = id
            }
            .id(newId)
        }
      } else {
        if apiViewModel.myFollow.followingCount == 0 {
          Spacer()
          followEmptyView()
        } else {
          myFollowingList()
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
          log("dismiss")
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
      await apiViewModel.requestMyFollow()
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
      if userName != apiViewModel.myProfile.userName {
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
            isFollowed.wrappedValue.toggle()
            apiViewModel.postFeedPlayerChanged()
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
    Text("아직 회원님을 팔로우하는 사람이 없습니다")
      .fontSystem(fontDesignSystem: .body1_KO)
      .foregroundColor(.LabelColor_Secondary)
      .padding(.bottom, 64)
  }

  @ViewBuilder
  func myFollowerList() -> some View {
    ForEach(apiViewModel.myFollow.followerList, id: \.userName) { follower in
      NavigationLink {
        if UIDevice.current.userInterfaceIdiom == .phone {
          switch UIScreen.main.nativeBounds.height {
          case 1334: // iPhone SE 3rd generation
            SEUserProfileView(players: .constant([]), currentIndex: .constant(0), userId: follower.followerId)
              .environmentObject(apiViewModel)
              .environmentObject(tabbarModel)
              .id(UUID())
          default:
            UserProfileView(players: .constant([]), currentIndex: .constant(0), userId: follower.followerId)
              .environmentObject(apiViewModel)
              .environmentObject(tabbarModel)
              .id(UUID())
          }
        }
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

  @ViewBuilder
  func myFollowingList() -> some View {
    ForEach(apiViewModel.myFollow.followingList, id: \.userName) { following in
      NavigationLink {
        if UIDevice.current.userInterfaceIdiom == .phone {
          switch UIScreen.main.nativeBounds.height {
          case 1334: // iPhone SE 3rd generation
            SEUserProfileView(players: .constant([]), currentIndex: .constant(0), userId: following.followingId)
              .environmentObject(apiViewModel)
              .environmentObject(tabbarModel)
              .id(UUID())
          default:
            UserProfileView(players: .constant([]), currentIndex: .constant(0), userId: following.followingId)
              .environmentObject(apiViewModel)
              .environmentObject(tabbarModel)
              .id(UUID())
          }
        }
      } label: {
        personRow(
          isFollowed: Binding(get: {
            following.isFollowed
          }, set: { newValue in
            following.isFollowed = newValue
          }),
          userName: following.userName,
          description: following.userName,
          profileImage: following.profileImg,
          userId: following.followingId)
      }
      .id(UUID())
    }
  }
}
