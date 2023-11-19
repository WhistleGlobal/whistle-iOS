//
//  MyFollowingList.swift
//  Whistle
//
//  Created by 박상원 on 11/6/23.
//

import SwiftUI

// MARK: - MyFollowingList

struct MyFollowingList: View {
  @ObservedObject var apiViewModel = APIViewModel.shared
  var filteredFollowing: [FollowingData]
  var body: some View {
    ScrollView {
      VStack(spacing: 0) {
        ForEach(filteredFollowing, id: \.userName) { following in
          NavigationLink {
            ProfileView(
              profileType:
              following.followingId == apiViewModel.myProfile.userId
                ? .my
                : .member,
              isFirstProfileLoaded: .constant(true),
              userId: following.followingId)
              .environmentObject(apiViewModel)
          } label: {
            PersonRow(
              isFollowed: Binding(get: {
                following.isFollowed
              }, set: { newValue in
                following.isFollowed = newValue
              }),
              userName: following.userName,
              description: following.userName,
              profileImage: following.profileImg,
              userID: following.followingId)
          }
          .id(UUID())
        }
        Spacer().frame(height: 150)
      }
    }
    .scrollIndicators(.hidden)
  }
}
