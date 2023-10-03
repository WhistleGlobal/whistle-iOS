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
  @State var offsetY: CGFloat = 0
  let userId: Int

  var body: some View {
    ZStack {
      Color.clear.overlay {
        if let url = apiViewModel.userProfile.profileImg, !url.isEmpty {
          KFImage.url(URL(string: url))
            .placeholder { _ in
              Image("DefaultBG")
                .resizable()
                .scaledToFill()
                .blur(radius: 50)
            }
            .resizable()
            .scaledToFill()
            .scaleEffect(2.0)
            .blur(radius: 50)
        } else {
          Image("DefaultBG")
            .resizable()
            .scaledToFill()
            .blur(radius: 50)
        }
      }
      VStack {
        Spacer().frame(height: topSpacerHeight)
        glassProfile(
          width: .infinity,
          height: 418 + (240 * progress),
          cornerRadius: profileCornerRadius,
          overlayed: profileInfo(height: 418 + (240 * progress)))
          .padding(.horizontal, profileHorizontalPadding)
          .zIndex(1)
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
                    .id(UUID())
                } label: {
                  videoThumbnailView(
                    thumbnailUrl: content.thumbnailUrl ?? "",
                    viewCount: content.contentViewCount ?? 0)
                }
                .id(UUID())
              }
            }
            .padding(.horizontal, 16)
            .offset(coordinateSpace: .named("SCROLL")) { offset in
              offsetY = offset
            }
            Spacer().frame(height: 800)
          }
          .scrollIndicators(.hidden)
          .coordinateSpace(name: "SCROLL")
          .zIndex(0)
          Spacer()
        }
      }
      .ignoresSafeArea()
    }
    .overlay {
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
        Spacer()
      }
      .padding(16)
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
    }
    .task {
      log(userId)
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
      Spacer().frame(height: 64)
      profileImageView(url: apiViewModel.userProfile.profileImg, size: profileImageSize)
        .padding(.bottom, 16)
      Text(apiViewModel.userProfile.userName)
        .foregroundColor(Color.LabelColor_Primary_Dark)
        .fontSystem(fontDesignSystem: .title2_Expanded)

      Color.clear.overlay {
        Text(apiViewModel.userProfile.introduce ?? " ")
          .foregroundColor(Color.LabelColor_Secondary_Dark)
          .fontSystem(fontDesignSystem: .body2_KO)
          .lineLimit(nil)
          .multilineTextAlignment(.center)
          .fixedSize(horizontal: false, vertical: true)
          .scaleEffect(introduceScale)
          .padding(.bottom, 16)
      }
      .frame(height: introduceHeight)
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
      .scaleEffect(profileEditButtonScale)
      .padding(.bottom, 24)
      HStack(spacing: 48) {
        VStack(spacing: 4) {
          Text("\(apiViewModel.userWhistleCount)")
            .foregroundColor(Color.LabelColor_Primary_Dark)
            .fontSystem(fontDesignSystem: .title2_Expanded)
            .scaleEffect(whistleFollowerTextScale)
          Text("whistle")
            .foregroundColor(Color.LabelColor_Secondary_Dark)
            .fontSystem(fontDesignSystem: .caption_SemiBold)
            .scaleEffect(whistleFollowerTextScale)
        }
        Rectangle().frame(width: 1 , height: .infinity).foregroundColor(.white)
        NavigationLink {
          UserFollowView(userId: userId)
            .environmentObject(apiViewModel)
            .environmentObject(tabbarModel)
            .id(UUID())
        } label: {
          VStack(spacing: 4) {
            Text("\(apiViewModel.userFollow.followerCount)")
              .foregroundColor(Color.LabelColor_Primary_Dark)
              .fontSystem(fontDesignSystem: .title2_Expanded)
              .scaleEffect(whistleFollowerTextScale)
            Text("follower")
              .foregroundColor(Color.LabelColor_Secondary_Dark)
              .fontSystem(fontDesignSystem: .caption_SemiBold)
              .scaleEffect(whistleFollowerTextScale)
          }
        }
        .id(UUID())
      }
      .frame(height: whistleFollowerTabHeight)
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

extension UserProfileView {
  var progress: CGFloat {
    -(offsetY / 177) > 1 ? -1 : (offsetY > 0 ? 0 : (offsetY / 177))
  }

  var progressOpacity: CGFloat {
    abs(1 + (progress * 1.5)) > 1 ? 0 : 1 + (progress * 1.5)
  }

  var profileHorizontalPadding: CGFloat {
    switch -offsetY {
    case ..<0:
      return 16
    case 0..<64:
      return 16 + (16 * (offsetY / 64))
    default:
      return 0
    }
  }

  var profileCornerRadius: CGFloat {
    switch -offsetY {
    case ..<0:
      return 32
    case 0..<64:
      return 32 + (32 * (offsetY / 64))
    default:
      return 0
    }
  }

  var topSpacerHeight: CGFloat {
    switch -offsetY {
    case ..<0:
      return 64
    case 0..<64:
      return 64 + offsetY
    default:
      return 0
    }
  }

  var profileImageSize: CGFloat {
    switch -offsetY {
    case ..<0:
      return 100
    case 0..<122:
      return 100 + (100 * (offsetY / 122))
    default:
      return 0
    }
  }

  var whistleFollowerTabHeight: CGFloat {
    switch -offsetY {
    case ..<122:
      return 54
    case 122..<200:
      return 54 + (54 * ((offsetY + 122) / 78))
    default:
      return 0
    }
  }

  var whistleFollowerTextScale: CGFloat {
    switch -offsetY {
    case ..<122:
      return 1
    case 122..<200:
      return 1 - abs((offsetY + 122) / 78)
    default:
      return 0
    }
  }

  var profileEditButtonHeight: CGFloat {
    switch -offsetY {
    case ..<200:
      return 36
    case 200..<252:
      return 36 + (36 * ((offsetY + 200) / 52))
    default:
      return 0
    }
  }

  var profileEditButtonWidth: CGFloat {
    switch -offsetY {
    case ..<200:
      return 114
    case 200..<252:
      return 114 + (114 * ((offsetY + 200) / 52))
    default:
      return 0
    }
  }

  var profileEditButtonScale: CGFloat {
    switch -offsetY {
    case ..<200:
      return 1
    case 200..<252:
      return 1 - abs((offsetY + 200) / 52)
    default:
      return 0
    }
  }

  var introduceHeight: CGFloat {
    switch -offsetY {
    case ..<252:
      return 20
    case 252..<305:
      return 20 + (20 * ((offsetY + 252) / 53))
    default:
      return 0
    }
  }

  var introduceScale: CGFloat {
    switch -offsetY {
    case ..<252:
      return 1
    case 252..<305:
      return 1 - abs((offsetY + 252) / 53)
    default:
      return 0
    }
  }

  var tabOffset: CGFloat {
    switch -offsetY {
    case ..<252:
      return 0
    case 252..<305:
      return offsetY + 252
    case 305...:
      return -60
    default:
      return 0
    }
  }
}
