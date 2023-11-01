//
//  MyProfileView.swift
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

// MARK: - MyProfileView

struct MyProfileView: View {
  @StateObject var userAuth = UserAuth.shared
  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject private var tabbarModel = TabbarModel.shared
  @StateObject private var toastViewModel = ToastViewModel.shared
  @StateObject var alertViewModel = AlertViewModel.shared
  @StateObject private var feedPlayersViewModel = MainFeedPlayersViewModel.shared

  @State var showProfileEditView = false
  @State private var goNotiSetting = false
  @State var isShowingBottomSheet = false
  @State var tabbarDirection: CGFloat = -1.0
  @State var tabSelection: profileTabCase = .myVideo
  @State var bottomSheetPosition: BottomSheetPosition = .hidden
  @State var offsetY: CGFloat = 0

  @Binding var isFirstProfileLoaded: Bool
  let processor = BlurImageProcessor(blurRadius: 10)
  let center = UNUserNotificationCenter.current()

  var body: some View {
    ZStack {
      if bottomSheetPosition == .absolute(420) {
        DimmedBackground().zIndex(1000)
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
          glassProfile(
            cornerRadius: profileCornerRadius,
            overlayed: profileInfo())
            .frame(
              height: UIScreen.getHeight(418 + (240 * progress)))
            .padding(.bottom, 12)
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
                  MyFeedView(index: index)
                } label: {
                  videoThumbnailView(
                    thumbnailURL: content.thumbnailUrl ?? "",
                    whistleCount: content.whistleCount ?? 0)
                }
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
                  videoThumbnailView(thumbnailURL: content.thumbnailUrl, whistleCount: content.whistleCount)
                }
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
      }
      .ignoresSafeArea()
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
            .fontSystem(fontDesignSystem: .subtitle1_KO)
            .foregroundColor(.white)
          Spacer()
          Button {
            bottomSheetPosition = .hidden
          } label: {
            Text(CommonWords().cancel)
              .fontSystem(fontDesignSystem: .subtitle2_KO)
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

extension MyProfileView {
  @ViewBuilder
  func profileInfo() -> some View {
    VStack(spacing: 0) {
      if UIDevice.current.userInterfaceIdiom == .phone {
        switch UIScreen.main.nativeBounds.height {
        case 1334: // iPhone SE 3rd generation
          Spacer().frame(height: topSpacerHeightSE + 20)
        default:
          Spacer().frame(height: UIScreen.getHeight(64))
        }
      }
      profileImageView(
        url: apiViewModel.myProfile.profileImage,
        size: UIScreen.getHeight(profileImageSize))
        .padding(.bottom, 16)
      Text(apiViewModel.myProfile.userName)
        .foregroundColor(Color.LabelColor_Primary_Dark)
        .fontSystem(fontDesignSystem: .title2_Expanded)
        .offset(y: usernameOffset)
        .padding(.bottom, UIScreen.getHeight(4))
      Spacer()
      Color.clear.overlay {
        Text(apiViewModel.myProfile.introduce ?? "")
          .foregroundColor(Color.LabelColor_Secondary_Dark)
          .fontSystem(fontDesignSystem: .body2_KO)
          .lineLimit(2)
          .truncationMode(.tail)
          .multilineTextAlignment(.center)
          .fixedSize(horizontal: false, vertical: true)
          .scaleEffect(introduceScale)
      }
      .frame(height: UIScreen.getHeight(introduceHeight))
      .padding(.bottom, UIScreen.getHeight(16))
      .padding(.horizontal, UIScreen.getWidth(48))
      Spacer()
      Button {
        showProfileEditView = true
      } label: {
        Text(ProfileEditWords().edit)
          .fontSystem(fontDesignSystem: .subtitle2_KO)
          .foregroundColor(Color.LabelColor_Primary_Dark)
          .scaleEffect(profileEditButtonScale)
          .frame(width: UIScreen.getWidth(profileEditButtonWidth), height: UIScreen.getHeight(profileEditButtonHeight))
      }
      .frame(width: UIScreen.getWidth(profileEditButtonWidth), height: UIScreen.getHeight(profileEditButtonHeight))
      .padding(.bottom, UIScreen.getHeight(24))
      .buttonStyle(ProfileEditButtonStyle())
      HStack(spacing: 0) {
        VStack(spacing: 4) {
          Text("\(apiViewModel.myWhistleCount)")
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
          MyFollowListView()
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
  func videoThumbnailView(thumbnailURL: String, whistleCount: Int) -> some View {
    Color.black.overlay {
      KFImage.url(URL(string: thumbnailURL))
        .placeholder {
          Color.black
        }
        .resizable()
        .scaledToFit()
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
    .frame(height: 204)
    .cornerRadius(12)
  }

  @ViewBuilder
  func listEmptyView() -> some View {
    Spacer()
    Text(ContentWords().noUploadedContent).fontSystem(fontDesignSystem: .body1_KO)
      .foregroundColor(.LabelColor_Primary_Dark)
    Button {
      tabbarModel.tabSelectionNoAnimation = .upload
      withAnimation {
        tabbarModel.tabSelection = .upload
      }
    } label: {
      Text(ContentWords().goUpload)
        .fontSystem(fontDesignSystem: .subtitle2_KO)
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
      .fontSystem(fontDesignSystem: .body1_KO)
      .foregroundColor(.LabelColor_Primary_Dark)
      .padding(.bottom, 64)
    Spacer()
  }
}

// MARK: - Sticky Header Computed Properties

extension MyProfileView {
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

extension MyProfileView {
  var filteredFollower: [FollowerData] {
    apiViewModel.myFollow.followerList.filter { !BlockList.shared.userIds.contains($0.followerId) }
  }
}
