//
//  UserProfileView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/9/23.
//

import _AVKit_SwiftUI
import Kingfisher
import SwiftUI

// MARK: - UserProfileView

struct UserProfileView: View {

  @Environment(\.dismiss) var dismiss
  @EnvironmentObject var apiViewModel: APIViewModel
  @State var isFollow = false
  @State var showDialog = false
  @State var goReport = false
  let userId: Int

  var body: some View {
    ZStack {
      Color.clear.overlay {
        Image("testCat")
          .resizable()
          .scaledToFill()
          .ignoresSafeArea()
          .blur(radius: 8)
      }
      VStack {
        Spacer().frame(height: 64)
        glassView(width: UIScreen.width - 32)
          .padding(.bottom, 12)
        if apiViewModel.userPostFeed.isEmpty {
          Spacer()
          Image(systemName: "photo.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 48, height: 48)
            .foregroundColor(.LabelColor_Primary_Dark)
            .padding(.bottom, 24)
          Text("아직 게시물이 없습니다.")
            .fontSystem(fontDesignSystem: .body1_KO)
            .foregroundColor(.LabelColor_Primary_Dark)
            .padding(.bottom, 76)
          Spacer()
        } else {
          ScrollView {
            LazyVGrid(columns: [
              GridItem(.flexible()),
              GridItem(.flexible()),
              GridItem(.flexible()),
            ], spacing: 20) {
              ForEach(apiViewModel.userPostFeed, id: \.self) { content in
                videoThumbnailView(
                  url: content.videoUrl ?? "",
                  viewCount: content.contentViewCount ?? 0)
              }
            }
          }
          Spacer()
        }
      }
      .padding(.horizontal, 16)
      .ignoresSafeArea()
    }
    .navigationBarBackButtonHidden()
    .confirmationDialog("", isPresented: $showDialog) {
      Button("신고", role: .destructive) {
        goReport = true
      }
      Button("취소", role: .cancel) {
        log("Cancel")
      }
    }
    .navigationDestination(isPresented: $goReport) {
      ReportUserView()
    }
    .task {
      await apiViewModel.requestUserProfile(userId: userId)
      await apiViewModel.requestUserFollow(userId: userId)
      await apiViewModel.requestUserWhistlesCount(userId: userId)
      isFollow = apiViewModel.userProfile.isFollowed == 1 ? true : false
      log(isFollow)
    }
    .task {
      await apiViewModel.requestUserPostFeed(userId: userId)
    }
  }
}

extension UserProfileView {

  // FIXME: - 색상 적용 안됨
  @ViewBuilder
  func glassView(width: CGFloat, height: CGFloat = 398) -> some View {
    glassMorphicCard(width: width, height: height)
      .overlay {
        RoundedRectangle(cornerRadius: 32)
          .stroke(lineWidth: 1)
          .foregroundStyle(
            LinearGradient.Border_Glass)
        profileInfo(height: height)
      }
  }

  @ViewBuilder
  func profileInfo(height: CGFloat) -> some View {
    VStack(spacing: 0) {
      HStack {
        Button {
          dismiss()
        } label: {
          Image(systemName: "chevron.left")
            .foregroundColor(Color.White)
            .fontWeight(.semibold)
            .frame(width: 48, height: 48)
            .background(
              Circle()
                .foregroundColor(.Gray_Default)
                .frame(width: 48, height: 48))
        }
        Spacer()
        Button {
          // FIXME: - 신고 동작 추가
          showDialog = true
        } label: {
          Image(systemName: "ellipsis")
            .foregroundColor(Color.White)
            .fontWeight(.semibold)
            .frame(width: 48, height: 48)
            .background(
              Circle()
                .foregroundColor(.Gray_Default)
                .frame(width: 48, height: 48))
        }
      }
      .padding([.top, .horizontal], 16)
      KFImage.url(URL(string: apiViewModel.userProfile.profileImg))
        .placeholder {
          Image("ProfileDefault")
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
        }
        .resizable()
        .scaledToFill()
        .frame(width: 100, height: 100)
        .clipShape(Circle())
        .padding(.bottom, 16)
      Text(apiViewModel.userProfile.userName)
        .foregroundColor(Color.LabelColor_Primary_Dark)
        .fontSystem(fontDesignSystem: .title2_Expanded)
      Text(apiViewModel.userProfile.introduce ?? "")
        .foregroundColor(Color.LabelColor_Secondary_Dark)
        .fontSystem(fontDesignSystem: .body2_KO)
        .padding(.bottom, 16)
      // FIXME: - 팔로잉 팔로워 버튼으로 만들기
      Button("") {
        Task {
          if isFollow {
            isFollow.toggle()
            await apiViewModel.unfollowUser(userId: userId)
          } else {
            isFollow.toggle()
            await apiViewModel.followUser(userId: userId)
          }
        }
      }
      .buttonStyle(FollowButtonStyle(isFollowed: $isFollow))
      .padding(.bottom, 24)
      HStack(spacing: 48) {
        VStack(spacing: 4) {
          Text("\(apiViewModel.userWhistleCount)")
            .foregroundColor(Color.LabelColor_Primary_Dark)
            .fontSystem(fontDesignSystem: .title2_Expanded)
          Text("whistle")
            .foregroundColor(Color.LabelColor_Secondary_Dark)
            .fontSystem(fontDesignSystem: .caption_SemiBold)
        }
        Rectangle().frame(width: 1, height: 36).foregroundColor(.white)
        NavigationLink {
          FollowView(userId: userId)
            .environmentObject(apiViewModel)
        } label: {
          VStack(spacing: 4) {
            Text("\(apiViewModel.userFollow.followerCount)")
              .foregroundColor(Color.LabelColor_Primary_Dark)
              .fontSystem(fontDesignSystem: .title2_Expanded)
            Text("follower")
              .foregroundColor(Color.LabelColor_Secondary_Dark)
              .fontSystem(fontDesignSystem: .caption_SemiBold)
          }
        }
      }
      Spacer()
    }
    .frame(height: height)
    .frame(maxWidth: .infinity)
  }

  @ViewBuilder
  func videoThumbnailView(url: String, viewCount: Int) -> some View {
    VideoPlayer(
      player: AVPlayer(url: URL(string: url)!))
      .disabled(true)
      .frame(height: 204)
      .cornerRadius(12)
      .overlay {
        VStack {
          Spacer()
          HStack(spacing: 4) {
            Image(systemName: "play.circle.fill")
              .resizable()
              .scaledToFit()
              .frame(width: 17, height: 17)
              .foregroundColor(.Primary_Default)
            Text("\(viewCount)")
              .fontSystem(fontDesignSystem: .caption_KO_Semibold)
              .foregroundColor(Color.LabelColor_Primary_Dark)
          }
          .padding(.bottom, 8.5)
          .padding(.leading, 8)
          .frame(maxWidth: .infinity, alignment: .leading)
        }
      }
  }
}
