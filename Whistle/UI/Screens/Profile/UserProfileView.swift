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
  @State var showBlockAlert = false
  @State var showUnblockAlert = false
  @State var showBlockToast = false
  @State var showUnblockToast = false
  @State var goReport = false
  @State var showPasteToast = false
  @State var offsetY: CGFloat = 0
  @State var isProfileLoaded = false
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
          height: 418 + (240 * progress) + profileHeightLast,
          cornerRadius: profileCornerRadius,
          overlayed: profileInfo())
          .padding(.horizontal, profileHorizontalPadding)
          .zIndex(1)
          .padding(.bottom, 12)
        if apiViewModel.userPostFeed.isEmpty {
          if !(apiViewModel.userProfile.isBlocked == 1) {
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
          }
          Spacer()
        } else {
          ScrollView {
            LazyVGrid(columns: [
              GridItem(.flexible()),
              GridItem(.flexible()),
              GridItem(.flexible()),
            ], spacing: 20) {
              ForEach(Array(apiViewModel.userPostFeed.enumerated()), id: \.element) { index, content in
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
      if apiViewModel.myProfile.userId != userId {
        Button(apiViewModel.userProfile.isBlocked == 1 ? "차단 해제" : "차단", role: .destructive) {
          if apiViewModel.userProfile.isBlocked == 1 {
            showUnblockAlert = true
          } else {
            showBlockAlert = true
          }
        }
        Button("신고", role: .destructive) {
          goReport = true
        }
      }
      Button("프로필 URL 복사", role: .none) {
        UIPasteboard.general.setValue(
          "https://readywhistle.com/profile_uni?id=\(userId)",
          forPasteboardType: UTType.plainText.identifier)
        showPasteToast = true
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
      isFollow = apiViewModel.userProfile.isFollowed == 1 ? true : false
      isProfileLoaded = true
      await apiViewModel.requestUserFollow(userId: userId)
      await apiViewModel.requestUserWhistlesCount(userId: userId)
    }
    .task {
      log(userId)
      await apiViewModel.requestUserPostFeed(userId: userId)
    }
    .overlay {
      if showPasteToast {
        ToastMessage(text: "클립보드에 복사되었어요", toastPadding: 78, showToast: $showPasteToast)
      }
      if showBlockAlert {
        ToastMessage(text: "\(apiViewModel.userProfile.userName)님이 차단되었습니다.", toastPadding: 72, showToast: $showBlockToast)
      }
      if showUnblockToast {
        ToastMessage(text: "\(apiViewModel.userProfile.userName)님이 차단 해제되었습니다.", toastPadding: 72, showToast: $showUnblockToast)
      }
    }
    .overlay {
      if showUnblockAlert {
        AlertPopup(
          alertStyle: .linear,
          title: "\(apiViewModel.userProfile.userName) 님을 해제하시겠어요?",
          content: "이제 상대방이 회원님의 게시물을 보거나 팔로우할 수 있습니다. 상대방에게 회원님이 차단을 해제했다는 정보를 알리지 않습니다.",
          cancelText: "취소", destructiveText:"차단해제",cancelAction: {
            showUnblockAlert = false
          }, destructiveAction: {
            showUnblockAlert = false
            Task {
              await apiViewModel.actionBlockUserCancel(userId: userId)
              Task {
                await apiViewModel.requestUserProfile(userId: userId)
                await apiViewModel.requestUserPostFeed(userId: userId)
              }
              Task {
                await apiViewModel.requestUserFollow(userId: userId)
                await apiViewModel.requestUserWhistlesCount(userId: userId)
              }
            }
          })
      }
      if showBlockAlert {
        AlertPopup(
          alertStyle: .linear,
          title: "\(apiViewModel.userProfile.userName) 님을 차단하시겠어요?",
          content: "차단된 사람은 회원님의 프로필 또는 콘텐츠를 찾을 수 없게 되며, 상대방에게 차단되었다는 알림이 전송되지 않습니다.",
          cancelText: "취소", destructiveText:"차단",cancelAction: {
            showBlockAlert = false
          }, destructiveAction: {
            showBlockAlert = false
            Task {
              await apiViewModel.actionBlockUser(userId: userId)
              Task {
                await apiViewModel.requestUserProfile(userId: userId)
                await apiViewModel.requestUserPostFeed(userId: userId)
              }
              Task {
                await apiViewModel.requestUserFollow(userId: userId)
                await apiViewModel.requestUserWhistlesCount(userId: userId)
              }
            }
          })
      }
    }
    .onAppear {
      if !players.isEmpty {
        players[currentIndex]?.pause()
      }
    }
  }
}

extension UserProfileView {
  @ViewBuilder
  func profileInfo() -> some View {
    VStack(spacing: 0) {
      Spacer().frame(height: 64)
      profileImageView(url: apiViewModel.userProfile.profileImg, size: profileImageSize)
        .padding(.bottom, 16)
      Text(apiViewModel.userProfile.userName)
        .foregroundColor(Color.LabelColor_Primary_Dark)
        .fontSystem(fontDesignSystem: .title2_Expanded)
      Spacer().frame(maxHeight: 20)
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
      if apiViewModel.userProfile.isBlocked == 1 {
        Button {
          showUnblockAlert = true
        } label: {
          unblockButton
        }
        .padding(.bottom, 24)
      } else {
        Capsule()
          .frame(width: 112, height: 36)
          .foregroundColor(isProfileLoaded ? .clear : .Gray_Default)
          .overlay {
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
            .opacity(isProfileLoaded ? 1 : 0)
            .disabled(userId == apiViewModel.myProfile.userId)
          }
          .padding(.bottom, 24)
          .scaleEffect(profileEditButtonScale)
      }
      HStack(spacing: 0) {
        VStack(spacing: 4) {
          if apiViewModel.userProfile.isBlocked == 1 {
            Text("0")
              .foregroundColor(Color.LabelColor_Primary_Dark)
              .fontSystem(fontDesignSystem: .title2_Expanded)
              .scaleEffect(whistleFollowerTextScale)
          } else {
            Text("\(apiViewModel.userWhistleCount)")
              .foregroundColor(Color.LabelColor_Primary_Dark)
              .fontSystem(fontDesignSystem: .title2_Expanded)
              .scaleEffect(whistleFollowerTextScale)
          }
          Text("휘슬")
            .foregroundColor(Color.LabelColor_Secondary_Dark)
            .fontSystem(fontDesignSystem: .caption_SemiBold)
            .scaleEffect(whistleFollowerTextScale)
        }
        .hCenter()
        Rectangle().frame(width: 1, height: .infinity).foregroundColor(.white)
        NavigationLink {
          UserFollowView(userId: userId)
            .environmentObject(apiViewModel)
            .environmentObject(tabbarModel)
            .id(UUID())
        } label: {
          VStack(spacing: 4) {
            if apiViewModel.userProfile.isBlocked == 1 {
              Text("0")
                .foregroundColor(Color.LabelColor_Primary_Dark)
                .fontSystem(fontDesignSystem: .title2_Expanded)
                .scaleEffect(whistleFollowerTextScale)
            } else {
              Text("\(apiViewModel.userFollow.followerCount)")
                .foregroundColor(Color.LabelColor_Primary_Dark)
                .fontSystem(fontDesignSystem: .title2_Expanded)
                .scaleEffect(whistleFollowerTextScale)
            }
            Text("팔로워")
              .foregroundColor(Color.LabelColor_Secondary_Dark)
              .fontSystem(fontDesignSystem: .caption_SemiBold)
              .scaleEffect(whistleFollowerTextScale)
          }
          .hCenter()
        }
        .disabled(apiViewModel.userProfile.isBlocked == 1)
        .id(UUID())
      }
      .frame(height: whistleFollowerTabHeight)
      Spacer()
    }
    .frame(height: 418 + (240 * progress) + profileHeightLast)
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
        .offset(y: 64 - topSpacerHeight)
        .padding(.horizontal, 16 - profileHorizontalPadding)
        Spacer()
      }
      .padding(16)
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
    .frame(height: 204)
    .cornerRadius(12)
  }

  @ViewBuilder
  var unblockButton: some View {
    Text("차단해제")
      .fontSystem(fontDesignSystem: .subtitle3_KO)
      .foregroundColor(.LabelColor_Primary_Dark)
      .padding(.horizontal, 20)
      .padding(.vertical, 6)
      .background {
        Capsule()
          .foregroundColor(.Primary_Default)
      }
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
    case 0 ..< 64:
      return 16 + (16 * (offsetY / 64))
    default:
      return 0
    }
  }

  var profileCornerRadius: CGFloat {
    switch -offsetY {
    case ..<0:
      return 32
    case 0 ..< 64:
      return 32 + (32 * (offsetY / 64))
    default:
      return 0
    }
  }

  var topSpacerHeight: CGFloat {
    switch -offsetY {
    case ..<0:
      return 64
    case 0 ..< 64:
      return 64 + offsetY
    default:
      return 0
    }
  }

  var profileImageSize: CGFloat {
    switch -offsetY {
    case ..<0:
      return 100
    case 0 ..< 122:
      return 100 + (100 * (offsetY / 122))
    default:
      return 0
    }
  }

  var whistleFollowerTabHeight: CGFloat {
    switch -offsetY {
    case ..<122:
      return 54
    case 122 ..< 200:
      return 54 + (54 * ((offsetY + 122) / 78))
    default:
      return 0
    }
  }

  var whistleFollowerTextScale: CGFloat {
    switch -offsetY {
    case ..<122:
      return 1
    case 122 ..< 200:
      return 1 - abs((offsetY + 122) / 78)
    default:
      return 0
    }
  }

  var profileEditButtonHeight: CGFloat {
    switch -offsetY {
    case ..<200:
      return 36
    case 200 ..< 252:
      return 36 + (36 * ((offsetY + 200) / 52))
    default:
      return 0
    }
  }

  var profileEditButtonWidth: CGFloat {
    switch -offsetY {
    case ..<200:
      return 114
    case 200 ..< 252:
      return 114 + (114 * ((offsetY + 200) / 52))
    default:
      return 0
    }
  }

  var profileEditButtonScale: CGFloat {
    switch -offsetY {
    case ..<200:
      return 1
    case 200 ..< 252:
      return 1 - abs((offsetY + 200) / 52)
    default:
      return 0
    }
  }

  var introduceHeight: CGFloat {
    switch -offsetY {
    case ..<252:
      return 20
    case 252 ..< 305:
      return 20 + (20 * ((offsetY + 252) / 53))
    default:
      return 0
    }
  }

  var introduceScale: CGFloat {
    switch -offsetY {
    case ..<252:
      return 1
    case 252 ..< 305:
      return 1 - abs((offsetY + 252) / 53)
    default:
      return 0
    }
  }

  var tabOffset: CGFloat {
    switch -offsetY {
    case ..<252:
      return 0
    case 252 ..< 305:
      return offsetY + 252
    case 305...:
      return -60
    default:
      return 0
    }
  }

  var profileHeightLast: CGFloat {
    switch -offsetY {
    case ..<252:
      return 0
    case 252 ..< 305:
      return (offsetY + 252) / 53 * 36
    case 305...:
      return -36
    default:
      return 0
    }
  }

  var videoOffset: CGFloat {
    log("\(offsetY < -305 ? 305 : -offsetY)")
    return offsetY < -305 ? 305 : -offsetY
  }
}
