//
//  PersonRow.swift
//  Whistle
//
//  Created by 박상원 on 11/6/23.
//

import SwiftUI

struct PersonRow: View {
  @StateObject var apiViewModel = APIViewModel.shared
  @Binding var isFollowed: Bool
  var userName: String
  var description: String?
  var profileImage: String?
  var userID: Int

  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        profileImageView(url: profileImage, size: 48)
        VStack(spacing: 0) {
          Text(userName)
            .fontSystem(fontDesignSystem: .subtitle2)
            .foregroundColor(.labelColorPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
          if !(description ?? "").isEmpty {
            Text(description ?? "")
              .fontSystem(fontDesignSystem: .body2)
              .foregroundColor(.LabelColor_Secondary)
              .frame(maxWidth: .infinity, alignment: .leading)
              .multilineTextAlignment(.leading)
          }
        }
        .padding(.leading, 16)
        if userName != apiViewModel.myProfile.userName {
          Button("") {
            Task {
              if $isFollowed.wrappedValue {
                await apiViewModel.followAction(userID: userID, method: .delete)
                apiViewModel.mainFeed = apiViewModel.mainFeed.map { content in
                  let updatedContent = content
                  if content.userId == userID {
                    updatedContent.isFollowed.toggle()
                  }
                  return updatedContent
                }
              } else {
                await apiViewModel.followAction(userID: userID, method: .post)
                apiViewModel.mainFeed = apiViewModel.mainFeed.map { content in
                  let updatedContent = content
                  if content.userId == userID {
                    updatedContent.isFollowed.toggle()
                  }
                  return updatedContent
                }
              }
              $isFollowed.wrappedValue.toggle()
              apiViewModel.publisherSend()
            }
          }
          .buttonStyle(FollowButtonStyle(isFollowed: $isFollowed))
        }
      }
      .padding(.horizontal, 16)
      .frame(height: 72)
      .frame(maxWidth: .infinity)
      Divider().frame(height: 0.5).padding(.leading, 80)
        .foregroundColor(.labelColorDisablePlaceholder)
    }
  }
}
