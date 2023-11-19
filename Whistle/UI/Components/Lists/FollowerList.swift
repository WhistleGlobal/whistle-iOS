//
//  FollowerList.swift
//  Whistle
//
//  Created by 박상원 on 11/6/23.
//

import SwiftUI

// MARK: - FollowerList

struct FollowerList: View {
  @ObservedObject var apiViewModel = APIViewModel.shared
  var filteredFollower: [FollowerData]

  var body: some View {
    ScrollView {
      VStack(spacing: 0) {
        ForEach(filteredFollower, id: \.userName) { follower in
          NavigationLink {
            ProfileView(
              profileType:
              follower.followerId == apiViewModel.myProfile.userId
                ? .my
                : .member,
              isFirstProfileLoaded: .constant(true),
              userId: follower.followerId)
              .environmentObject(apiViewModel)
          } label: {
            PersonRow(
              isFollowed: Binding(get: {
                follower.isFollowed
              }, set: { newValue in
                follower.isFollowed = newValue
              }),
              userName: follower.userName,
              description: follower.userName,
              profileImage: follower.profileImg,
              userID: follower.followerId)
          }
          .id(UUID())
        }
        Spacer().frame(height: 150)
      }
    }
    .scrollIndicators(.hidden)
  }
}
