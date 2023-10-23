//
//  SEMyProfileView.swift
//  Whistle
//
//  Created by ChoiYujin on 10/10/23.
//

import AVKit
import BottomSheet
import GoogleSignIn
import GoogleSignInSwift
import Kingfisher
import SwiftUI

// MARK: - SEMyProfileView

struct SEMyProfileView: View {

  @StateObject var userAuth = UserAuth.shared
  @StateObject private var tabbarModel = TabbarModel.shared
  @StateObject var apiViewModel = APIViewModel.shared

  @State var isShowingBottomSheet = false
  @State var tabbarDirection: CGFloat = -1.0
  @State var tabSelection: profileTabCase = .myVideo

  @State var showSignoutAlert = false
  @State var showDeleteAlert = false
  @State var showPasteToast = false

  @State var bottomSheetPosition: BottomSheetPosition = .hidden
  @State var offsetY: CGFloat = 0
  @Binding var isFirstProfileLoaded: Bool

  let processor = BlurImageProcessor(blurRadius: 10)
  var body: some View {
    ZStack {
      Color.clear.overlay {
        if let url = apiViewModel.myProfile.profileImage, !url.isEmpty {
          KFImage.url(URL(string: url))
            .placeholder { _ in
              Image("BlurredDefaultBG")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            }
            .resizable()
            .setProcessor(processor)
            .scaledToFill()
            .scaleEffect(2.0)
        } else {
          Image("BlurredDefaultBG")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
        }
      }
      VStack(spacing: 0) {
        VStack(spacing: 0) {
          Spacer().frame(height: topSpacerHeight)
          glassProfile(
            cornerRadius: profileCornerRadius,
            overlayed: profileInfo())
            .frame(height: 278 + (146 * progress))
            .padding(.bottom, 8)
        }
        .padding(.horizontal, profileHorizontalPadding)
        .zIndex(1)
        Color.clear.overlay {
          HStack(spacing: 0) {
            Button {
              tabSelection = .myVideo
            } label: {
              Color.gray
                .opacity(0.01)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .buttonStyle(MyFeedTabItemButtonStyle(
              systemName: "square.grid.2x2.fill",
              tab: profileTabCase.myVideo.rawValue,
              selectedTab: $tabSelection))
            Button {
              tabSelection = .bookmark
            } label: {
              Color.gray
                .opacity(0.01)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .buttonStyle(MyFeedTabItemButtonStyle(
              systemName: "bookmark.fill",
              tab: profileTabCase.bookmark.rawValue,
              selectedTab: $tabSelection))
          }
          .frame(height: 48)
          .offset(y: tabOffset)
        }
        .frame(height: tabHeight)
        .padding(.bottom, tabPadding)
        .zIndex(2)
        switch (tabSelection, apiViewModel.myFeed.isEmpty, apiViewModel.bookmark.isEmpty) {
        // 내 비디오 탭 & 올린 컨텐츠 있음
        case (.myVideo, false, _):
          ScrollView {
            LazyVGrid(columns: [
              GridItem(.flexible()),
              GridItem(.flexible()),
              GridItem(.flexible()),
            ], spacing: 20) {
              ForEach(Array(apiViewModel.myFeed.enumerated()), id: \.element) { index, content in
                NavigationLink {
                  MyFeedView(currentIndex: index)

                } label: {
                  videoThumbnailView(
                    thumbnailUrl: content.thumbnailUrl ?? "",
                    viewCount: content.contentViewCount ?? 0)
                }
              }
            }
            .offset(y: videoOffset)
            .offset(coordinateSpace: .named("SCROLL")) { offset in
              offsetY = offset
            }
            Spacer().frame(height: 800)
          }
          .padding(.horizontal, 16)
          .scrollIndicators(.hidden)
          .coordinateSpace(name: "SCROLL")
          .zIndex(0)
          Spacer()
        // 북마크 탭 & 올린 컨텐츠 있음
        case (.bookmark, _, false):
          ScrollView {
            LazyVGrid(columns: [
              GridItem(.flexible()),
              GridItem(.flexible()),
              GridItem(.flexible()),
            ], spacing: 20) {
              ForEach(Array(apiViewModel.bookmark.enumerated()), id: \.element) { index, content in

                NavigationLink {
                  BookmarkedFeedView(currentIndex: index)

                } label: {
                  videoThumbnailView(thumbnailUrl: content.thumbnailUrl, viewCount: content.viewCount)
                }
              }
            }
            .offset(y: videoOffset)
            .offset(coordinateSpace: .named("SCROLL")) { offset in
              offsetY = offset
            }
            Spacer().frame(height: 800)
          }
          .padding(.horizontal, 16)
          .scrollIndicators(.hidden)
          .coordinateSpace(name: "SCROLL")
          .zIndex(0)
          Spacer()
        // 내 비디오 탭 & 올린 컨텐츠 없음
        case (.myVideo, true, _):
          listEmptyView()
            .padding(.horizontal, 16)
        // 북마크 탭 & 올린 컨텐츠 없음
        case (.bookmark, _, true):
          bookmarkEmptyView()
            .padding(.horizontal, 16)
        }
      }
      .ignoresSafeArea()
    }
    .overlay {
      if showSignoutAlert {
        AlertPopup(alertStyle: .linear, title: "정말 로그아웃하시겠어요?", cancelText: "취소", destructiveText: "로그아웃") {
          showSignoutAlert = false
        } destructiveAction: {
          apiViewModel.reset()
          GIDSignIn.sharedInstance.signOut()
          userAuth.appleSignout()
          isFirstProfileLoaded = false
        }
      }
      if showDeleteAlert {
        AlertPopup(
          alertStyle: .linear,
          title: "정말 삭제하시겠어요?",
          content: "삭제하시면 회원님의 모든 정보와 활동 기록이 삭제됩니다. 삭제된 정보는 복구할 수 없으니 신중하게 결정해주세요.",
          cancelText: "취소",
          destructiveText: "삭제")
        {
          showDeleteAlert = false
        } destructiveAction: {
          Task {
            apiViewModel.myProfile.userName.removeAll()
            await apiViewModel.rebokeAppleToken()
            GIDSignIn.sharedInstance.signOut()
            userAuth.appleSignout()
            isFirstProfileLoaded = true
          }
        }
      }
    }
    .overlay {
      if showPasteToast {
        ToastMessage(text: "클립보드에 복사되었어요", toastPadding: 78, showToast: $showPasteToast)
      }
    }
    .onChange(of: bottomSheetPosition) { newValue in
      if newValue == .hidden {
        tabbarModel.tabbarOpacity = 1.0
      } else {
        tabbarModel.tabbarOpacity = 0.0
      }
    }
    .bottomSheet(
      bottomSheetPosition: $bottomSheetPosition,
      switchablePositions: [.hidden, .absolute(420)])
    {
      VStack(spacing: 0) {
        HStack {
          Text("설정")
            .fontSystem(fontDesignSystem: .subtitle1_KO)
            .foregroundColor(.White)
        }
        .frame(height: 52)
        Divider().background(Color("Gray10"))
        NavigationLink {
          NotificationSettingView()

        } label: {
          bottomSheetRowWithIcon(systemName: "bell", iconWidth: 22, iconHeight: 20, text: "알림")
        }
        NavigationLink {
          LegalInfoView()

        } label: {
          bottomSheetRowWithIcon(systemName: "info.circle", iconWidth: 22, iconHeight: 20, text: "약관 및 정책")
        }
        Button {
          withAnimation {
            bottomSheetPosition = .hidden
          }
          UIPasteboard.general.setValue(
            "https://readywhistle.com/profile_uni?id=\(apiViewModel.myProfile.userId)",
            forPasteboardType: UTType.plainText.identifier)
          showPasteToast = true
        } label: {
          bottomSheetRowWithIcon(systemName: "square.and.arrow.up", iconWidth: 22, iconHeight: 20, text: "프로필 공유")
        }
        NavigationLink {
          GuideStatusView()

        } label: {
          bottomSheetRowWithIcon(
            systemName: "exclamationmark.triangle.fill",
            iconWidth: 22,
            iconHeight: 20,
            text: "신고")
        }
        Group {
          Divider().background(Color("Gray10"))
          Button {
            withAnimation {
              bottomSheetPosition = .hidden
            }
            showSignoutAlert = true
          } label: {
            bottomSheetRow(text: "로그아웃", color: Color.Info)
          }
          Button {
            withAnimation {
              bottomSheetPosition = .hidden
            }
            showDeleteAlert = true
          } label: {
            bottomSheetRow(text: "계정삭제", color: Color.Danger)
          }
        }
        Spacer()
      }
      .frame(height: 420)
    }
    .enableSwipeToDismiss(true)
    .enableTapToDismiss(true)
    .enableContentDrag(true)
    .enableAppleScrollBehavior(false)
    .dragIndicatorColor(Color.Border_Default_Dark)
    .customBackground(
      glassMorphicView(cornerRadius: 24)
        .overlay {
          RoundedRectangle(cornerRadius: 24)
            .stroke(lineWidth: 1)
            .foregroundStyle(
              LinearGradient.Border_Glass)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        })
    .onDismiss {
      tabbarModel.tabbarOpacity = 1.0
    }
  }
}

extension SEMyProfileView {
  @ViewBuilder
  func profileInfo() -> some View {
    VStack(spacing: 0) {
      Spacer().frame(height: 48)
      profileImageView(url: apiViewModel.myProfile.profileImage, size: profileImageSize)
        .padding(.bottom, 12)
      Text(apiViewModel.myProfile.userName)
        .font(.system(size: 18, weight: .semibold).width(.expanded))
        .foregroundColor(Color.LabelColor_Primary_Dark)
        .frame(height: 28)
      Spacer().frame(minHeight: 10)
      Color.clear.overlay {
        Text(apiViewModel.myProfile.introduce ?? " ")
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
      NavigationLink {
        ProfileEditView()

      } label: {
        Text("프로필 편집")
          .fontSystem(fontDesignSystem: .subtitle2_KO)
          .foregroundColor(Color.LabelColor_Primary_Dark)
          .scaleEffect(profileEditButtonScale)
          .frame(width: profileEditButtonWidth, height: profileEditButtonHeight)
      }
      .frame(width: profileEditButtonWidth, height: profileEditButtonHeight)
      .padding(.bottom, 16)
      .buttonStyle(ProfileEditButtonStyle())
      HStack(spacing: 48) {
        VStack(spacing: 4) {
          Text("\(apiViewModel.myWhistleCount)")
            .foregroundColor(Color.LabelColor_Primary_Dark)
            .font(.system(size: 16, weight: .semibold).width(.expanded))
            .scaleEffect(whistleFollowerTextScale)
          Text("whistle")
            .foregroundColor(Color.LabelColor_Secondary_Dark)
            .font(.system(size: 10, weight: .semibold))
            .scaleEffect(whistleFollowerTextScale)
        }
        Rectangle().frame(width: 1, height: .infinity).foregroundColor(.white)
        NavigationLink {
          MyFollowListView()

        } label: {
          VStack(spacing: 4) {
            Text("\(apiViewModel.myFollow.followerCount)")
              .foregroundColor(Color.LabelColor_Primary_Dark)
              .font(.system(size: 16, weight: .semibold).width(.expanded))
              .scaleEffect(whistleFollowerTextScale)
            Text("follower")
              .foregroundColor(Color.LabelColor_Secondary_Dark)
              .font(.system(size: 10, weight: .semibold))
              .scaleEffect(whistleFollowerTextScale)
          }
        }
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
          Spacer()
          Button {
            withAnimation {
              bottomSheetPosition = .absolute(420)
            }
          } label: {
            Circle()
              .foregroundColor(.Gray_Default)
              .frame(width: 40, height: 40)
              .overlay {
                Image(systemName: "ellipsis")
                  .resizable()
                  .scaledToFit()
                  .foregroundColor(Color.White)
                  .fontWeight(.semibold)
                  .frame(width: 20, height: 20)
              }
          }
          .offset(y: 28 - topSpacerHeight)
          .padding(.top, 16)
          .padding(.horizontal, 16 - profileHorizontalPadding)
        }
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
        .placeholder {
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

  @ViewBuilder
  func listEmptyView() -> some View {
    Spacer()
    Text("공유하고 싶은 첫번째 콘텐츠를 업로드해보세요")
      .fontSystem(fontDesignSystem: .body1_KO)
      .foregroundColor(.LabelColor_Primary_Dark)
    Button {
      tabbarModel.tabSelectionNoAnimation = .upload
      withAnimation {
        tabbarModel.tabSelection = .upload
      }
    } label: {
      Text("업로드하러 가기")
        .fontSystem(fontDesignSystem: .subtitle2_KO)
        .foregroundColor(Color.LabelColor_Primary_Dark)
        .frame(width: 142, height: 36)
    }
    .buttonStyle(ProfileEditButtonStyle())
    .padding(.bottom, 76)
    Spacer()
  }
}

extension SEMyProfileView {
  @ViewBuilder
  func bottomSheetRowWithIcon(
    systemName: String,
    iconWidth: CGFloat,
    iconHeight: CGFloat,
    text: String)
    -> some View
  {
    HStack(spacing: 12) {
      Image(systemName: systemName)
        .resizable()
        .scaledToFit()
        .frame(width: iconWidth, height: iconHeight)
        .foregroundColor(.white)

      Text(text)
        .foregroundColor(.white)
        .fontSystem(fontDesignSystem: .body1_KO)
      Spacer()
      Image(systemName: "chevron.forward")
        .resizable()
        .scaledToFit()
        .padding(.vertical, 2.5)
        .padding(.horizontal, 6)
        .frame(width: 24, height: 24)
        .foregroundColor(.white)
    }
    .frame(height: 56)
    .padding(.horizontal, 16)
  }

  @ViewBuilder
  func bottomSheetRow(text: String, color: Color) -> some View {
    HStack {
      Text(text)
        .foregroundColor(color)
        .fontSystem(fontDesignSystem: .body1_KO)
      Spacer()
      Image(systemName: "chevron.forward")
        .resizable()
        .scaledToFit()
        .padding(.vertical, 2.5)
        .padding(.horizontal, 6)
        .frame(width: 24, height: 24)
        .foregroundColor(.white)
    }
    .frame(height: 56)
    .padding(.horizontal, 16)
  }

  @ViewBuilder
  func bookmarkEmptyView() -> some View {
    Spacer()
    Text("저장한 콘텐츠가 없습니다")
      .fontSystem(fontDesignSystem: .body1_KO)
      .foregroundColor(.LabelColor_Primary_Dark)
      .padding(.bottom, 64)
    Spacer()
  }
}

// MARK: - Sticky Header Computed Properties

extension SEMyProfileView {
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
    case 0 ..< 28:
      return 16 + (16 * (offsetY / 28))
    default:
      return 0
    }
  }

  var profileCornerRadius: CGFloat {
    switch -offsetY {
    case ..<0:
      return 32
    case 0 ..< 28:
      return 32 + (32 * (offsetY / 28))
    default:
      return 0
    }
  }

  var topSpacerHeight: CGFloat {
    switch -offsetY {
    case ..<0:
      return 28
    case 0 ..< 28:
      return 28 + offsetY
    default:
      return 0
    }
  }

  var profileImageSize: CGFloat {
    switch -offsetY {
    case ..<0:
      return 56
    case 0 ..< 68:
      return 56 + (56 * (offsetY / 68))
    default:
      return 0
    }
  }

  var whistleFollowerTabHeight: CGFloat {
    switch -offsetY {
    case ..<68:
      return 42
    case 68 ..< 126:
      return 42 + (42 * ((offsetY + 68) / 58))
    default:
      return 0
    }
  }

  var whistleFollowerTextScale: CGFloat {
    switch -offsetY {
    case ..<122:
      return 1
    case 68 ..< 126:
      return 1 - abs((offsetY + 68) / 58)
    default:
      return 0
    }
  }

  var profileEditButtonHeight: CGFloat {
    switch -offsetY {
    case ..<126:
      return 36
    case 126 ..< 146:
      return 28 + (28 * ((offsetY + 126) / 20))
    default:
      return 0
    }
  }

  var profileEditButtonWidth: CGFloat {
    switch -offsetY {
    case ..<126:
      return 114
    case 126 ..< 146:
      return 79 + (79 * ((offsetY + 126) / 20))
    default:
      return 0
    }
  }

  var profileEditButtonScale: CGFloat {
    switch -offsetY {
    case ..<126:
      return 1
    case 126 ..< 146:
      return 1 - abs((offsetY + 126) / 20)
    default:
      return 0
    }
  }

  var introduceHeight: CGFloat {
    switch -offsetY {
    case ..<146:
      return 20
    case 146 ..< 202:
      return 20 + (20 * ((offsetY + 146) / 56))
    default:
      return 0
    }
  }

  var introduceScale: CGFloat {
    switch -offsetY {
    case ..<146:
      return 1
    case 146 ..< 202:
      return 1 - abs((offsetY + 146) / 56)
    default:
      return 0
    }
  }

  var tabOffset: CGFloat {
    switch -offsetY {
    case ..<146:
      return 0
    case 146 ..< 202:
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
    case 146 ..< 202:
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
    case 146 ..< 202:
      return 48 + (48 * ((offsetY + 146) / 56))
    case 202...:
      return 0
    default:
      return 0
    }
  }

  var videoOffset: CGFloat {
    offsetY < -202 ? 202 : -offsetY
  }
}
