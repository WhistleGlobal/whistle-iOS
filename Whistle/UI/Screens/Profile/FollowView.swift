//
//  FollowView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/2/23.
//

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
  @EnvironmentObject var userViewModel: UserViewModel
  @State var tabStatus: profileTabStatus = .follower
  // FIXME: - 나중에 User Follower 모델 로 변경할 것
  @State var followPeoples: [Any] = []

  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        Button("") {
          tabStatus = .follower
        }
        .buttonStyle(
          FollowTabbarStyle(
            followNum: userViewModel.myFollow.followerCount,
            tab: profileTabStatus.follower.rawValue,
            selectedTab: $tabStatus))
        Button("") {
          tabStatus = .following
        }
        .buttonStyle(
          FollowTabbarStyle(
            followNum: userViewModel.myFollow.followingCount,
            tab: profileTabStatus.following.rawValue,
            selectedTab: $tabStatus))
      }
      .frame(height: 48)

      if tabStatus == .follower {
        if userViewModel.myFollow.followerCount == 0 {
          Spacer()
          Image(systemName: "person.fill")
            .resizable()
            .scaledToFit()
            .foregroundColor(.LabelColor_Primary)
            .frame(width: 48, height: 48)
            .padding(.bottom, 32)
          Text("아직 회원님\(tabStatus == .follower ? "이" : "을") 팔로우하는 사람이 없습니다")
            .fontSystem(fontDesignSystem: .body1_KO)
            .foregroundColor(.LabelColor_Secondary)

        } else {
          ForEach(userViewModel.myFollow.followerList, id: \.userName) { follower in
            personRow(
              isFollow: follower.isFollowed == 1,
              userName: follower.userName,
              description: follower.userName)
          }
        }
      } else {
        if userViewModel.myFollow.followingCount == 0 {
          Spacer()
          Image(systemName: "person.fill")
            .resizable()
            .scaledToFit()
            .foregroundColor(.LabelColor_Primary)
            .frame(width: 48, height: 48)
            .padding(.bottom, 32)
          Text("아직 회원님\(tabStatus == .follower ? "이" : "을") 팔로우하는 사람이 없습니다")
            .fontSystem(fontDesignSystem: .body1_KO)
            .foregroundColor(.LabelColor_Secondary)
        } else {
          ForEach(userViewModel.myFollow.followingList, id: \.userName) { following in
            personRow(
              isFollow: false,
              userName: following.userName,
              description: following.userName)
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
      userViewModel.requestMyFollow()
    }
  }
}

extension FollowView {
  @ViewBuilder
  func personRow(isFollow: Bool, userName: String, description: String) -> some View {
    HStack(spacing: 0) {
      Circle()
        .frame(width: 48, height: 48)
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
        log("Button pressed")
      }
      .buttonStyle(FollowButtonStyle(isFollow: isFollow))
      Spacer()
    }
    .frame(height: 72)
    .frame(maxWidth: .infinity)
  }

  @ViewBuilder
  func followEmptyView() -> some View {
    VStack(spacing: 24) {
      Image(systemName: "person.fill")
        .resizable()
        .scaledToFit()
        .frame(width: 48, height: 48)
        .foregroundColor(.LabelColor_Primary)
      Text("아직 회원님을 팔로우하는 사람이 없습니다")
        .fontSystem(fontDesignSystem: .body1_KO)
        .foregroundColor(.LabelColor_Secondary)
    }
    .frame(maxHeight: .infinity)
  }
}
