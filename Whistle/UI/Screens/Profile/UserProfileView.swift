//
//  UserProfileView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/9/23.
//

import _AVKit_SwiftUI
import Kingfisher
import SwiftUI
import UniformTypeIdentifiers

// MARK: - UserProfileView

struct UserProfileView: View {

  @Environment(\.dismiss) var dismiss
  @EnvironmentObject var apiViewModel: APIViewModel
  @EnvironmentObject var tabbarModel: TabbarModel
  @State var isFollow = false
  @State var showDialog = false
  @State var goReport = false
  @State var showPasteToast = false
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
        glassProfile(width: UIScreen.width - 32, height: 398, cornerRadius: 32, overlayed: profileInfo(height: 398))
          .padding(.bottom, 12)
        if apiViewModel.userPostFeed.isEmpty {
          Spacer()
          Image(systemName: "photo.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 48, height: 48)
            .foregroundColor(.LabelColor_Primary_Dark)
            .padding(.bottom, 24)
          Text("아직 콘텐츠가 없습니다.")
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
              ForEach(Array(apiViewModel.userPostFeed.enumerated()), id: \.element) { index ,content in
                NavigationLink {
                  UserContentListView(currentIndex: index)
                    .environmentObject(apiViewModel)
                    .environmentObject(tabbarModel)
                } label: {
                  videoThumbnailView(
                    thumbnailUrl: content.thumbnailUrl ?? "",
                    viewCount: content.contentViewCount ?? 0)
                }
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
      Button("프로필 URL 복사", role: .none) {
        UIPasteboard.general.setValue(
          "다른 유저 프로필 링크입니다.",
          forPasteboardType: UTType.plainText.identifier)
        showPasteToast = true
      }
      Button("신고", role: .destructive) {
        goReport = true
      }
      Button("취소", role: .cancel) {
        log("Cancel")
      }
    }
    .fullScreenCover(isPresented: $goReport) {
      ReportUserView(goReport: $goReport, userId: userId)
        .environmentObject(apiViewModel)
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
    .overlay {
      if showPasteToast {
        ToastMessage(text: "클립보드에 복사되었어요", paddingBottom: 0, showToast: $showPasteToast)
      }
    }
  }
}

extension UserProfileView {

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
      profileImageView(url: apiViewModel.userProfile.profileImg, size: 100)
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
            .environmentObject(tabbarModel)
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
  func videoThumbnailView(thumbnailUrl: String, viewCount: Int) -> some View {
    Color.black.overlay {
      KFImage.url(URL(string: thumbnailUrl))
        .placeholder { // 플레이스 홀더 설정
          Color.black
        }
        .resizable()
        .scaledToFit()
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
    .frame(height: 204)
    .cornerRadius(12)
  }
}
