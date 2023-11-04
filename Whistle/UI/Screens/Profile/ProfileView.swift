//
//  ProfileView.swift
//  Whistle
//
//  Created by ChoiYujin on 8/29/23.
//

import AVKit
import BottomSheet
import GoogleSignIn
import GoogleSignInSwift
import Kingfisher
import SwiftUI

// MARK: - profileTabCase

public enum profileTabCase: String {
  case myVideo
  case bookmark
}

// MARK: - ProfileView

struct ProfileView: View {
  @Environment(\.dismiss) var dismiss
  @StateObject var userAuth = UserAuth.shared
  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject private var tabbarModel = TabbarModel.shared
  @StateObject private var toastViewModel = ToastViewModel.shared
  @StateObject var alertViewModel = AlertViewModel.shared
  @StateObject private var feedPlayersViewModel = MainFeedPlayersViewModel.shared

  @State var bottomSheetPosition: BottomSheetPosition = .hidden
  @State var showProfileEditView = false
  @State var goNotiSetting = false
  @State var tabSelection: profileTabCase = .myVideo
  @State var profileType: ProfileType = .my
  @State var offsetY: CGFloat = 0
  @State var isProfileLoaded = false
  @State var isFirstStack = false
  @Binding var isFirstProfileLoaded: Bool
  let processor = BlurImageProcessor(blurRadius: 10)
  let center = UNUserNotificationCenter.current()
  let userId: Int

  var body: some View {
    ZStack {
      if bottomSheetPosition == .absolute(420) {
        DimsThick().zIndex(1000)
      }
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
          if UIDevice.current.userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1334: // iPhone SE 3rd generation
              Spacer().frame(height: topSpacerHeightSE * 2)
            default:
              Spacer().frame(height: topSpacerHeight)
            }
          }
          profileCardLayer()
            .background {
              glassProfile(
                cornerRadius: profileCornerRadius)
            }
            .padding(.bottom, 12)
        }
        .padding(.horizontal, profileHorizontalPadding)
        .zIndex(1)
        // contentTab
        if profileType == .my {
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
        }
        // content
        if profileType == .my {
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
                    MyFeedView(index: index)
                  } label: {
                    videoThumbnailView(
                      thumbnailUrl: content.thumbnailUrl ?? "",
                      whistleCount: content.whistleCount ?? 0)
                  }
                  .id(UUID())
                }
              }
              .offset(y: videoOffset)
              .offset(coordinateSpace: .named("SCROLL")) { offset in
                offsetY = offset
              }
              Spacer().frame(height: 1800)
            }
            .padding(.horizontal, 16)
            .scrollIndicators(.hidden)
            .coordinateSpace(name: "SCROLL")
            .zIndex(0)
            Spacer()
          // O 탭 & 올린 컨텐츠 있음
          case (.bookmark, _, false):
            ScrollView {
              LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
              ], spacing: 20) {
                ForEach(Array(apiViewModel.bookmark.enumerated()), id: \.element) { index, content in
                  NavigationLink {
                    BookMarkedFeedView(index: index)
                  } label: {
                    videoThumbnailView(thumbnailUrl: content.thumbnailUrl, whistleCount: content.whistleCount)
                  }
                  .id(UUID())
                }
              }
              .offset(y: UIScreen.getHeight(videoOffset))
              .offset(coordinateSpace: .named("SCROLL")) { offset in
                offsetY = offset
              }
              Spacer().frame(height: 1800)
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
        } else {
          if apiViewModel.memberFeed.isEmpty {
            if !apiViewModel.memberProfile.isBlocked {
              Spacer()
              Image(systemName: "photo.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .foregroundColor(.LabelColor_Primary_Dark)
                .padding(.bottom, 24)
              Text("아직 콘텐츠가 없습니다.")
                .fontSystem(fontDesignSystem: .body1)
                .foregroundColor(.LabelColor_Primary_Dark)
                .padding(.bottom, 76)
            } else {
              Spacer()
              Text("차단된 계정")
                .fontSystem(fontDesignSystem: .subtitle1)
                .foregroundColor(.LabelColor_Primary_Dark)
              Text("사용자에 의해 차단된 계정입니다")
                .fontSystem(fontDesignSystem: .body1)
                .foregroundColor(.LabelColor_Primary_Dark)
                .padding(.bottom, 56)
            }
            Spacer()
          } else {
            ScrollView {
              LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
              ], spacing: 20) {
                ForEach(Array(apiViewModel.memberFeed.enumerated()), id: \.element) { index, content in
                  NavigationLink {
                    MemberFeedView(index: index, userId: apiViewModel.memberFeed[index].userId ?? 0)
                  } label: {
                    videoThumbnailView(
                      thumbnailUrl: content.thumbnailUrl ?? "",
                      whistleCount: content.whistleCount ?? 0,
                      isHated: content.isHated)
                  }
                  .id(UUID())
                }
              }
              .padding(.horizontal, 16)
              .offset(y: videoOffset)
              .offset(coordinateSpace: .named("SCROLL")) { offset in
                offsetY = offset
              }
              Spacer().frame(height: 1800)
            }
            .scrollIndicators(.hidden)
            .coordinateSpace(name: "SCROLL")
            .zIndex(0)
            Spacer()
          }
        }
      }
      .ignoresSafeArea()
    }
    .navigationBarBackButtonHidden()
    .task {
      if profileType == .my {
        if isFirstProfileLoaded {
          await apiViewModel.requestMyProfile()
          isProfileLoaded = true
          await apiViewModel.requestMyFollow()
          await apiViewModel.requestMyWhistlesCount()
          isFirstProfileLoaded = false
        }
      } else {
        await apiViewModel.requestMemberProfile(userID: userId)
        isProfileLoaded = true
        await apiViewModel.requestMemberFollow(userID: userId)
        await apiViewModel.requestMemberWhistlesCount(userID: userId)
      }
    }
    .task {
      if profileType == .my {
        await apiViewModel.requestMyPostFeed()
      } else {
        await apiViewModel.requestMemberPostFeed(userID: userId)
      }
    }
    .onChange(of: bottomSheetPosition) { newValue in
      if newValue == .hidden {
        tabbarModel.tabbarOpacity = 1.0
      } else {
        tabbarModel.tabbarOpacity = 0.0
      }
    }
    .navigationDestination(isPresented: $goNotiSetting) {
      NotificationSettingView()
    }
    .bottomSheet(
      bottomSheetPosition: $bottomSheetPosition,
      switchablePositions: [.hidden, .absolute(420)])
    {
      VStack(spacing: 0) {
        HStack {
          Color.clear.frame(width: 28)
          Spacer()
          Text(CommonWords().settings)
            .fontSystem(fontDesignSystem: .subtitle1)
            .foregroundColor(.white)
          Spacer()
          Button {
            bottomSheetPosition = .hidden
          } label: {
            Text(CommonWords().cancel)
              .fontSystem(fontDesignSystem: .subtitle2)
              .foregroundColor(.white)
          }
        }
        .frame(height: 24)
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        Rectangle().frame(width: UIScreen.width, height: 1).foregroundColor(Color.Border_Default_Dark)
        Button {
          center.requestAuthorization(options: [.sound, .alert, .badge]) { granted, error in
            if let error {
              WhistleLogger.logger.error("\(error)")
              return
            }
            if !granted {
              alertViewModel.linearAlert(
                isRed: false,
                title: AlertTitles().setNotification,
                cancelText: CommonWords().cancel,
                destructiveText: AlertButtons().goSettings, cancelAction: { })
              {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                if UIApplication.shared.canOpenURL(url) {
                  UIApplication.shared.open(url)
                }
              }
            } else {
              goNotiSetting = true
            }
          }
        } label: {
          bottomSheetRowWithIcon(systemName: "bell", text: CommonWords().notification)
        }
        Rectangle().frame(height: 0.5).padding(.leading, 52).foregroundColor(Color.Border_Default_Dark)
        NavigationLink {
          LegalInfoView()
        } label: {
          bottomSheetRowWithIcon(systemName: "info.circle", text: CommonWords().about)
        }
        Rectangle().frame(height: 0.5).padding(.leading, 52).foregroundColor(Color.Border_Default_Dark)
        Button {
          withAnimation {
            bottomSheetPosition = .hidden
          }
          let shareURL = URL(
            string: "https://readywhistle.com/profile_uni?id=\(apiViewModel.myProfile.userId)")!
          let activityViewController = UIActivityViewController(activityItems: [shareURL], applicationActivities: nil)
          UIApplication.shared.windows.first?.rootViewController?.present(
            activityViewController,
            animated: true,
            completion: nil)
        } label: {
          bottomSheetRowWithIcon(systemName: "square.and.arrow.up", text: CommonWords().shareProfile)
        }
        Rectangle().frame(height: 0.5).padding(.leading, 52).foregroundColor(Color.Border_Default_Dark)
        NavigationLink {
          GuideStatusView()
        } label: {
          bottomSheetRowWithIcon(systemName: "exclamationmark.triangle.fill", text: CommonWords().guideStatus)
        }

        Group {
          Rectangle().frame(width: UIScreen.width, height: 1).foregroundColor(Color.Border_Default_Dark)
          Button {
            withAnimation {
              bottomSheetPosition = .hidden
            }
            alertViewModel.linearAlert(
              title: AlertTitles().logout,
              cancelText: CommonWords().cancel,
              destructiveText: CommonWords().logout)
            {
              NavigationUtil.popToRootView()
              isFirstProfileLoaded = true
              feedPlayersViewModel.resetPlayer()
              GIDSignIn.sharedInstance.signOut()
              userAuth.appleSignout()
              tabbarModel.tabSelectionNoAnimation = .main
              tabbarModel.tabSelection = .main
            }
          } label: {
            bottomSheetRow(text: CommonWords().logout, color: Color.Info)
          }
          Button {
            withAnimation {
              bottomSheetPosition = .hidden
            }
            alertViewModel.linearAlert(
              isRed: true,
              title: AlertTitles().removeAccount,
              content: AlertContents().removeAccount,
              cancelText: CommonWords().cancel,
              destructiveText: CommonWords().delete)
            {
              Task {
                apiViewModel.reset()
                apiViewModel.publisherSend()
                await apiViewModel.rebokeAppleToken()
                GIDSignIn.sharedInstance.signOut()
                userAuth.appleSignout()
                isFirstProfileLoaded = true
              }
            }
          } label: {
            bottomSheetRow(text: CommonWords().deleteAccount, color: Color.Danger)
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

extension ProfileView {
  @ViewBuilder
  func profileCardLayer() -> some View {
    VStack(spacing: 0) {
      // TopSpacing
      if UIDevice.current.userInterfaceIdiom == .phone {
        switch UIScreen.main.nativeBounds.height {
        case 1334: // iPhone SE 3rd generation
          Spacer().frame(height: topSpacerHeightSE + 20)
        default:
          Spacer().frame(height: UIScreen.getHeight(64))
        }
      }
      // Profile Image
      profileImageView(
        url: profileType == .my
          ? apiViewModel.myProfile.profileImage
          : apiViewModel.memberProfile.profileImg,
        size: UIScreen.getHeight(profileImageSize))
        .padding(.bottom, 16)
      // userName
      Text(
        profileType == .my
          ? apiViewModel.myProfile.userName
          : apiViewModel.memberProfile.userName)
        .foregroundColor(Color.LabelColor_Primary_Dark)
        .fontSystem(fontDesignSystem: .title2_Expanded)
        .offset(y: usernameOffset)
        .padding(.bottom, UIScreen.getHeight(4))
      // intruduce
      if profileType == .my, !(apiViewModel.myProfile.introduce ?? "").isEmpty {
        introduceText(text: apiViewModel.myProfile.introduce ?? "")
      } else if profileType == .member, !(apiViewModel.memberProfile.introduce ?? "").isEmpty {
        introduceText(text: apiViewModel.memberProfile.introduce ?? "")
      }
      // Edit button or Follow Button
      if profileType == .my {
        Button {
          showProfileEditView = true
        } label: {
          Text(ProfileEditWords().edit)
            .fontSystem(fontDesignSystem: .subtitle2)
            .foregroundColor(Color.LabelColor_Primary_Dark)
            .scaleEffect(profileEditButtonScale)
            .frame(
              width: UIScreen.getWidth(profileEditButtonWidth),
              height: UIScreen.getHeight(profileEditButtonHeight))
        }
        .frame(width: UIScreen.getWidth(profileEditButtonWidth), height: UIScreen.getHeight(profileEditButtonHeight))
        .padding(.bottom, UIScreen.getHeight(24))
        .buttonStyle(ProfileEditButtonStyle())
      } else {
        memberFollowBlockButton()
      }
      // Whistle or Follow count
      HStack(spacing: 0) {
        VStack(spacing: 4) {
          Text("\(profileType == .my ? apiViewModel.myWhistleCount : apiViewModel.memberWhistleCount)")
            .foregroundColor(Color.LabelColor_Primary_Dark)
            .fontSystem(fontDesignSystem: .title2_Expanded)
            .scaleEffect(whistleFollowerTextScale)
          Text(CommonWords().whistle)
            .foregroundColor(Color.LabelColor_Secondary_Dark)
            .fontSystem(fontDesignSystem: .caption_SemiBold)
            .scaleEffect(whistleFollowerTextScale)
        }
        .hCenter()
        Rectangle().frame(width: 1).foregroundColor(.white).scaleEffect(0.5)
        NavigationLink {
          if profileType == .my {
            MyFollowListView()
          } else {
            MemberFollowListView(userId: userId)
          }
        } label: {
          VStack(spacing: 4) {
            Text("\(filteredFollower.count)")
              .foregroundColor(Color.LabelColor_Primary_Dark)
              .fontSystem(fontDesignSystem: .title2_Expanded)
              .scaleEffect(whistleFollowerTextScale)
            Text(CommonWords().follower)
              .foregroundColor(Color.LabelColor_Secondary_Dark)
              .fontSystem(fontDesignSystem: .caption_SemiBold)
              .scaleEffect(whistleFollowerTextScale)
          }
          .hCenter()
        }
        .id(UUID())
      }
      .frame(height: UIScreen.getHeight(whistleFollowerTabHeight))
      .padding(.bottom, UIScreen.getHeight(32))
    }
    .fullScreenCover(isPresented: $showProfileEditView) {
      NavigationView {
        ProfileEditView()
      }
    }
    .frame(height: UIScreen.getHeight(418 + (240 * progress)))
    .frame(maxWidth: .infinity)
    .overlay {
      VStack(spacing: 0) {
        HStack {
          if profileType == .my, isFirstStack {
            Button {
              // 알림창 넘어가는 로직
            } label: {
              Circle()
                .foregroundColor(.Gray_Default)
                .frame(width: 48, height: 48)
                .overlay {
                  Image(systemName: "bell")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color.white)
                    .fontWeight(.semibold)
                    .frame(width: 20, height: 20)
                }
            }
            .offset(
              y: UIScreen.main.nativeBounds.height == 1334
                ? UIScreen.getHeight(20 - topSpacerHeightSE)
                : UIScreen.getHeight(64 - topSpacerHeight))
              .padding(.horizontal, 16 - profileHorizontalPadding)
          } else {
            Button {
              dismiss()
            } label: {
              Image(systemName: "chevron.left")
                .foregroundColor(.white)
                .fontWeight(.semibold)
                .frame(width: 48, height: 48)
                .background(
                  Circle()
                    .foregroundColor(.Gray_Default)
                    .frame(width: 48, height: 48))
            }
            .offset(
              y: UIScreen.main.nativeBounds.height == 1334
                ? UIScreen.getHeight(20 - topSpacerHeightSE)
                : UIScreen.getHeight(64 - topSpacerHeight))
              .padding(.horizontal, 16 - profileHorizontalPadding)
          }

          Spacer()
          Button {
            withAnimation {
              bottomSheetPosition = .absolute(420)
            }
          } label: {
            Circle()
              .foregroundColor(.Gray_Default)
              .frame(width: 48, height: 48)
              .overlay {
                Image(systemName: "ellipsis")
                  .resizable()
                  .scaledToFit()
                  .foregroundColor(Color.white)
                  .fontWeight(.semibold)
                  .frame(width: 20, height: 20)
              }
          }
          .offset(
            y: UIScreen.main.nativeBounds.height == 1334
              ? UIScreen.getHeight(20 - topSpacerHeightSE)
              : UIScreen.getHeight(64 - topSpacerHeight))
            .padding(.horizontal, 16 - profileHorizontalPadding)
        }
        Spacer()
      }
      .padding(16)
    }
  }

  @ViewBuilder
  func videoThumbnailView(thumbnailUrl: String, whistleCount: Int, isHated: Bool = false) -> some View {
    Color.black.overlay {
      KFImage.url(URL(string: thumbnailUrl))
        .placeholder { // 플레이스 홀더 설정
          Color.black
        }
        .resizable()
        .scaledToFit()
        .blur(radius: isHated ? 30 : 0, opaque: false)
        .scaleEffect(isHated ? 1.3 : 1)
        .overlay {
          if isHated {
            Image(systemName: "eye.slash.fill")
              .font(.system(size: 30))
              .foregroundColor(.Gray10)
          }
        }
      VStack {
        Spacer()
        HStack(spacing: 4) {
          Image(systemName: "heart.fill")
            .font(.system(size: 16))
            .foregroundColor(.Danger)
          Text("\(whistleCount)")
            .fontSystem(fontDesignSystem: .caption_SemiBold)
            .foregroundColor(Color.LabelColor_Primary_Dark)
        }
        .padding(.bottom, 8.5)
        .padding(.leading, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
    .frame(width: UIScreen.getWidth(204 * 9 / 16), height: UIScreen.getHeight(204))
    .cornerRadius(12)
  }

  @ViewBuilder
  func listEmptyView() -> some View {
    Spacer()
    Text(ContentWords().noUploadedContent).fontSystem(fontDesignSystem: .body1)
      .foregroundColor(.LabelColor_Primary_Dark)
    Button {
      tabbarModel.tabSelectionNoAnimation = .upload
      withAnimation {
        tabbarModel.tabSelection = .upload
      }
    } label: {
      Text(ContentWords().goUpload)
        .fontSystem(fontDesignSystem: .subtitle2)
        .foregroundColor(Color.LabelColor_Primary_Dark)
        .frame(width: 142, height: 36)
    }
    .buttonStyle(ProfileEditButtonStyle())
    .padding(.bottom, 76)
    Spacer()
  }

  @ViewBuilder
  func bookmarkEmptyView() -> some View {
    Spacer()
    Text(ContentWords().noBookmarkedContent)
      .fontSystem(fontDesignSystem: .body1)
      .foregroundColor(.LabelColor_Primary_Dark)
      .padding(.bottom, 64)
    Spacer()
  }
}

// MARK: - Sticky Header Computed Properties

extension ProfileView {
  var progress: CGFloat {
    -(offsetY / 177) > 1 ? -1 : (offsetY > 0 ? 0 : (offsetY / 177))
  }

  var progressOpacity: CGFloat {
    abs(1 + (progress * 1.5)) > 1 ? 0 : 1 + (progress * 1.5)
  }

  var profileHorizontalPadding: CGFloat {
    switch -offsetY {
    case ..<0:
      16
    case 0 ..< 64:
      16 + (16 * (offsetY / 64))
    default:
      0
    }
  }

  var profileCornerRadius: CGFloat {
    switch -offsetY {
    case ..<0:
      32
    case 0 ..< 64:
      32 + (32 * (offsetY / 64))
    default:
      0
    }
  }

  var topSpacerHeight: CGFloat {
    switch -offsetY {
    case ..<0:
      64
    case 0 ..< 64:
      64 + offsetY
    default:
      0
    }
  }

  var topSpacerHeightSE: CGFloat {
    switch -offsetY {
    case ..<0:
      20
    case 0 ..< 20:
      20 + offsetY
    default:
      0
    }
  }

  var profileImageSize: CGFloat {
    switch -offsetY {
    case ..<0:
      100
    case 0 ..< 122:
      100 + (100 * (offsetY / 122))
    default:
      0
    }
  }

  var whistleFollowerTabHeight: CGFloat {
    switch -offsetY {
    case ..<122:
      54
    case 122 ..< 200:
      54 + (54 * ((offsetY + 122) / 78))
    default:
      0
    }
  }

  var whistleFollowerTextScale: CGFloat {
    switch -offsetY {
    case ..<122:
      1
    case 122 ..< 200:
      1 - abs((offsetY + 122) / 78)
    default:
      0
    }
  }

  var profileEditButtonHeight: CGFloat {
    switch -offsetY {
    case ..<200:
      36
    case 200 ..< 252:
      36 + (36 * ((offsetY + 200) / 52))
    default:
      0
    }
  }

  var profileEditButtonWidth: CGFloat {
    switch -offsetY {
    case ..<200:
      114
    case 200 ..< 252:
      114 + (114 * ((offsetY + 200) / 52))
    default:
      0
    }
  }

  var profileEditButtonScale: CGFloat {
    switch -offsetY {
    case ..<200:
      1
    case 200 ..< 252:
      1 - abs((offsetY + 200) / 52)
    default:
      0
    }
  }

  var introduceHeight: CGFloat {
    switch -offsetY {
    case ..<252:
      20
    case 252 ..< 305:
      20 + (20 * ((offsetY + 252) / 53))
    default:
      0
    }
  }

  var introduceScale: CGFloat {
    switch -offsetY {
    case ..<252:
      1
    case 252 ..< 305:
      1 - abs((offsetY + 252) / 53)
    default:
      0
    }
  }

  var usernameOffset: CGFloat {
    switch -offsetY {
    case ..<252:
      0
    case 252 ..< 305:
      -20 * ((offsetY + 252) / 53)
    default:
      20
    }
  }

  var tabOffset: CGFloat {
    switch -offsetY {
    case ..<252:
      0
    case 252 ..< 305:
      36 * ((offsetY + 252) / 53)
    case 305...:
      -36
    default:
      0
    }
  }

  var tabPadding: CGFloat {
    switch -offsetY {
    case ..<252:
      16
    case 252 ..< 305:
      16 + (16 * ((offsetY + 252) / 53))
    case 305...:
      0
    default:
      0
    }
  }

  var tabHeight: CGFloat {
    switch -offsetY {
    case ..<252:
      48
    case 252 ..< 305:
      48 + (48 * ((offsetY + 252) / 53))
    case 305...:
      0
    default:
      0
    }
  }

  var videoOffset: CGFloat {
    offsetY < -305 ? 305 : -offsetY
  }
}

// MARK: - ProfileType

enum ProfileType {
  case my
  case member
}

extension ProfileView {

  @ViewBuilder
  var unblockButton: some View {
    Text(CommonWords().unblock)
      .fontSystem(fontDesignSystem: .subtitle3)
      .foregroundColor(.LabelColor_Primary_Dark)
      .padding(.horizontal, 20)
      .padding(.vertical, 6)
      .background {
        Capsule()
          .foregroundColor(.Primary_Default)
      }
  }

  var filteredFollower: [FollowerData] {
    if profileType == .my {
      apiViewModel.myFollow.followerList.filter { !BlockList.shared.userIds.contains($0.followerId) }
    } else {
      apiViewModel.memberFollow.followerList.filter { !BlockList.shared.userIds.contains($0.followerId) }
    }
  }

  @ViewBuilder
  func introduceText(text: String) -> some View {
    Color.clear.overlay {
      Text(text)
        .foregroundColor(Color.LabelColor_Secondary_Dark)
        .fontSystem(fontDesignSystem: .body2)
        .lineLimit(2)
        .truncationMode(.tail)
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        .scaleEffect(introduceScale)
    }
    .frame(height: UIScreen.getHeight(introduceHeight))
    .padding(.bottom, UIScreen.getHeight(16))
    .padding(.horizontal, UIScreen.getWidth(48))
  }

  @ViewBuilder
  func memberFollowBlockButton() -> some View {
    if apiViewModel.memberProfile.isBlocked {
      Button {
        alertViewModel.linearAlert(
          isRed: true,
          title: "\(apiViewModel.memberProfile.userName) 님을 차단 해제하시겠어요?",
          content: AlertContents().block,
          cancelText: CommonWords().cancel,
          destructiveText: CommonWords().unblock)
        {
          toastViewModel.toastInit(message: "\(apiViewModel.memberProfile.userName)님이 차단 해제되었습니다")
          Task {
            await apiViewModel.blockAction(userID: userId, method: .delete)
            BlockList.shared.userIds.append(userId)
            BlockList.shared.userIds = BlockList.shared.userIds.filter { $0 != userId }
            Task {
              await apiViewModel.requestMemberProfile(userID: userId)
              await apiViewModel.requestMemberPostFeed(userID: userId)
            }
            Task {
              await apiViewModel.requestMemberFollow(userID: userId)
              await apiViewModel.requestMemberWhistlesCount(userID: userId)
            }
          }
        }
      } label: {
        unblockButton
      }
      .padding(.bottom, UIScreen.getHeight(24))
    } else {
      Capsule()
        .frame(width: UIScreen.getWidth(112), height: UIScreen.getHeight(36))
        .foregroundColor(isProfileLoaded ? .clear : .Gray_Default)
        .overlay {
          Button("") {
            Task {
              if apiViewModel.memberProfile.isFollowed {
                apiViewModel.memberProfile.isFollowed.toggle()
                await apiViewModel.followAction(userID: userId, method: .delete)
              } else {
                apiViewModel.memberProfile.isFollowed.toggle()
                await apiViewModel.followAction(userID: userId, method: .post)
              }
            }
          }
          .buttonStyle(FollowButtonStyle(isFollowed: $apiViewModel.memberProfile.isFollowed))
          .scaleEffect(profileEditButtonScale)
          .opacity(isProfileLoaded ? 1 : 0)
          .disabled(userId == apiViewModel.myProfile.userId)
        }
        .padding(.bottom, UIScreen.getHeight(24))
        .scaleEffect(profileEditButtonScale)
    }
  }
}
