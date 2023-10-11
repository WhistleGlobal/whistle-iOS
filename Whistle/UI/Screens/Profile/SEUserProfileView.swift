//
//  SEUserProfileView.swift
//  Whistle
//
//  Created by ChoiYujin on 10/11/23.
//

import _AVKit_SwiftUI
import Kingfisher
import SwiftUI
import UniformTypeIdentifiers

// MARK: - SEUserProfileView

struct SEUserProfileView: View {

  @Environment(\.dismiss) var dismiss
  @EnvironmentObject var apiViewModel: APIViewModel
  @EnvironmentObject var tabbarModel: TabbarModel
  @State var isFollow = false
  @State var showDialog = false
  @State var goReport = false
  @State var showPasteToast = false
  @State var offsetY: CGFloat = 0
  @Binding var players: [AVPlayer?]
  @Binding var currentIndex: Int
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
          height: 278 + (146 * progress) + profileHeightLast,
          cornerRadius: profileCornerRadius,
          overlayed: profileInfo())
          .padding(.bottom, 8)
          .padding(.horizontal, profileHorizontalPadding)
          .zIndex(1)
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
            .offset(y: videoOffset)
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
    .navigationBarBackButtonHidden()
    .confirmationDialog("", isPresented: $showDialog) {
      Button("프로필 URL 복사", role: .none) {
        UIPasteboard.general.setValue(
          "https://readywhistle.com/profile_uni?id=\(userId)",
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
        ToastMessage(text: "클립보드에 복사되었어요", toastPadding: 78, showToast: $showPasteToast)
      }
    }
    .onAppear {
      if !players.isEmpty {
        players[currentIndex]?.pause()
      }
    }
  }
}

extension SEUserProfileView {

  @ViewBuilder
  func profileInfo() -> some View {
    VStack(spacing: 0) {
      Spacer().frame(height: 48)
      profileImageView(url: apiViewModel.userProfile.profileImg, size: profileImageSize)
        .padding(.bottom, 12)
      Text(apiViewModel.userProfile.userName)
        .font(.system(size: 18, weight: .semibold).width(.expanded))
        .foregroundColor(Color.LabelColor_Primary_Dark)
        .frame(height: 28)
      Spacer().frame(minHeight: 10)
      Color.clear.overlay {
        Text(apiViewModel.userProfile.introduce ?? " ")
          .foregroundColor(Color.LabelColor_Secondary_Dark)
          .font(.system(size: 14, weight: .regular))
          .fontSystem(fontDesignSystem: .body2_KO)
          .lineLimit(nil)
          .multilineTextAlignment(.center)
          .fixedSize(horizontal: false, vertical: true)
          .scaleEffect(introduceScale)
      }
      .frame(height: introduceHeight) // 20 max
      .padding(.bottom, 8)
      .padding(.horizontal, 48)
      Spacer()
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
      .padding(.bottom, 16)
      .disabled(userId == apiViewModel.myProfile.userId)
      HStack(spacing: 48) {
        VStack(spacing: 4) {
          Text("\(apiViewModel.userWhistleCount)")
            .foregroundColor(Color.LabelColor_Primary_Dark)
            .font(.system(size: 16, weight: .semibold).width(.expanded))
            .scaleEffect(whistleFollowerTextScale)
          Text("whistle")
            .foregroundColor(Color.LabelColor_Secondary_Dark)
            .font(.system(size: 10, weight: .semibold))
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
              .font(.system(size: 16, weight: .semibold).width(.expanded))
              .scaleEffect(whistleFollowerTextScale)
            Text("follower")
              .foregroundColor(Color.LabelColor_Secondary_Dark)
              .font(.system(size: 10, weight: .semibold))
              .scaleEffect(whistleFollowerTextScale)
          }
        }
        .id(UUID())
      }
      .frame(height: whistleFollowerTabHeight) // 42 max
      .padding(.bottom, 10)
      Spacer()
    }
    .frame(height: 278 + (146 * progress))
    .frame(maxWidth: .infinity)
    .overlay {
      VStack(spacing: 0) {
        HStack {
          Button {
            if !players.isEmpty {
              players[currentIndex]?.play()
            }
            dismiss()
          } label: {
            Image(systemName: "chevron.left")
              .foregroundColor(Color.White)
              .fontWeight(.semibold)
              .frame(width: 40, height: 40)
              .background(
                Circle()
                  .foregroundColor(.Gray_Default)
                  .frame(width: 40, height: 40))
          }
          Spacer()
          Button {
            showDialog = true
          } label: {
            Image(systemName: "ellipsis")
              .foregroundColor(Color.White)
              .fontWeight(.semibold)
              .frame(width: 40, height: 40)
              .background(
                Circle()
                  .foregroundColor(.Gray_Default)
                  .frame(width: 40, height: 40))
          }
        }
        .offset(y: 28 - topSpacerHeight)
        .padding(.top, 16)
        .padding(.horizontal, 16 - profileHorizontalPadding)
        Spacer()
      }
      .padding(.horizontal, 16)
      .padding(.top, 8)
    }
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
    .frame(height: UIScreen.getHeight(204))
    .cornerRadius(12)
  }
}

// MARK: - Sticky Header Computed Properties

extension SEUserProfileView {
  var progress: CGFloat {
    -(offsetY / 132) > 1 ? -1 : (offsetY > 0 ? 0 : (offsetY / 132))
  }

  var progressOpacity: CGFloat {
    abs(1 + (progress * 1.5)) > 1 ? 0 : 1 + (progress * 1.5)
  }

  var profileHorizontalPadding: CGFloat {
    switch -offsetY {
    case ..<0:
      return 16
    case 0..<28:
      return 16 + (16 * (offsetY / 28))
    default:
      return 0
    }
  }

  var profileCornerRadius: CGFloat {
    switch -offsetY {
    case ..<0:
      return 32
    case 0..<28:
      return 32 + (32 * (offsetY / 28))
    default:
      return 0
    }
  }

  var topSpacerHeight: CGFloat {
    switch -offsetY {
    case ..<0:
      return 28
    case 0..<28:
      return 28 + offsetY
    default:
      return 0
    }
  }

  var profileImageSize: CGFloat {
    switch -offsetY {
    case ..<0:
      return 56
    case 0..<68:
      return 56 + (56 * (offsetY / 68))
    default:
      return 0
    }
  }

  var whistleFollowerTabHeight: CGFloat {
    switch -offsetY {
    case ..<68:
      return 42
    case 68..<126:
      return 42 + (42 * ((offsetY + 68) / 58))
    default:
      return 0
    }
  }

  var whistleFollowerTextScale: CGFloat {
    switch -offsetY {
    case ..<122:
      return 1
    case 68..<126:
      return 1 - abs((offsetY + 68) / 58)
    default:
      return 0
    }
  }

  var profileEditButtonHeight: CGFloat {
    switch -offsetY {
    case ..<126:
      return 36
    case 126..<146:
      return 28 + (28 * ((offsetY + 126) / 20))
    default:
      return 0
    }
  }

  var profileEditButtonWidth: CGFloat {
    switch -offsetY {
    case ..<126:
      return 114
    case 126..<146:
      return 79 + (79 * ((offsetY + 126) / 20))
    default:
      return 0
    }
  }

  var profileEditButtonScale: CGFloat {
    switch -offsetY {
    case ..<126:
      return 1
    case 126..<146:
      return 1 - abs((offsetY + 126) / 20)
    default:
      return 0
    }
  }

  var introduceHeight: CGFloat {
    switch -offsetY {
    case ..<146:
      return 20
    case 146..<202:
      return 20 + (20 * ((offsetY + 146) / 56))
    default:
      return 0
    }
  }

  var introduceScale: CGFloat {
    switch -offsetY {
    case ..<146:
      return 1
    case 146..<202:
      return 1 - abs((offsetY + 146) / 56)
    default:
      return 0
    }
  }

  var tabOffset: CGFloat {
    switch -offsetY {
    case ..<146:
      return 0
    case 146..<202:
      return 32 * ((offsetY + 146) / 56)
    case 202...:
      return -32
    default:
      return 0
    }
  }

  var tabPadding: CGFloat {
    switch -offsetY {
    case ..<146:
      return 16
    case 146..<202:
      return 8 + (8 * ((offsetY + 146) / 56))
    case 202...:
      return 0
    default:
      return 0
    }
  }

  var tabHeight: CGFloat {
    switch -offsetY {
    case ..<146:
      return 48
    case 146..<202:
      return 48 + (48 * ((offsetY + 146) / 56))
    case 202...:
      return 0
    default:
      return 0
    }
  }

  var videoOffset: CGFloat {
    log("\(offsetY < -202 ? 202 : -offsetY)")
    return offsetY < -202 ? 202 : -offsetY
  }

  var profileHeightLast: CGFloat {
    switch -offsetY {
    case ..<146:
      return 0
    case 146..<202:
      return (offsetY + 146) / 56 * 32
    case 202...:
      return -32
    default:
      return 0
    }
  }
}
