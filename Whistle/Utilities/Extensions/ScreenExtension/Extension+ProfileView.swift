//
//  Extension+ProfileView.swift
//  Whistle
//
//  Created by ChoiYujin on 11/4/23.
//

import Foundation
import GoogleSignIn
import Kingfisher
import SwiftUI

// MARK: - Components

extension ProfileView {
  @ViewBuilder
  func navigationLinks() -> some View {
    Group {
      NavigationLink(
        destination: NotificationSettingView().tint(Color.labelColorPrimary).background(.backgroundDefault),
        isActive: $goNotiSetting)
      {
        EmptyView()
      }
      .id(UUID())
      NavigationLink(
        destination: LegalInfoView().background(.backgroundDefault),
        isActive: $goLegalInfo)
      {
        EmptyView()
      }
      .id(UUID())
      NavigationLink(
        destination: GuideStatusView().background(.backgroundDefault),
        isActive: $goGuideStatus)
      {
        EmptyView()
      }
      .id(UUID())
      NavigationLink(
        destination: MyTeamSelectView(),
        isActive: $goMyTeamSelect)
      {
        EmptyView()
      }
      .id(UUID())
      NavigationLink(
        destination: MyTeamSkinSettingView(),
        isActive: $goMyTeamSkinSelect)
      {
        EmptyView()
      }
      .id(UUID())
      NavigationLink(
        destination: WhistleRankingView(),
        isActive: $goWhistleRanking)
      {
        EmptyView()
      }
      .id(UUID())
    }
  }

  // MARK: - MyTeam
  @ViewBuilder
  func profileCardLayer() -> some View {
    ZStack {
      if let myTeam: String = {
        if profileType == .my {
          return apiViewModel.myProfile.myTeam
        } else {
          return apiViewModel.memberProfile.myTeam
        }
      }() {
        if isMyTeamBackgroundOn {
          MyTeamType.teamProfile(myTeam)
            .resizable()
            .scaledToFit()
        }
        if isMyTeamLabelOn {
          MyTeamType.teamLabel(myTeam)
            .resizable()
            .scaledToFit()
        }
      }

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
          size: UIScreen.getHeight(100))
          .padding(.bottom, UIScreen.getHeight(16))
        // userName
        Text(
          profileType == .my
            ? apiViewModel.myProfile.userName
            : apiViewModel.memberProfile.userName)
          .foregroundColor(Color.LabelColor_Primary_Dark)
          .fontSystem(fontDesignSystem: .title2_Expanded)
          .padding(.bottom, UIScreen.getHeight(4))
        // intruduce
        if profileType == .my {
          introduceText(text: apiViewModel.myProfile.introduce ?? "")
        } else if profileType == .member {
          introduceText(text: apiViewModel.memberProfile.introduce ?? "")
        }
        // Edit button or Follow Button
        if profileType == .my {
          Button {
            showProfileEditView = true
          } label: {
            Text(ProfileEditWords().edit)
              .font(.system(size: 16, weight: .semibold)) // subtitle 2
              .foregroundColor(Color.LabelColor_Primary_Dark)
              .frame(
                width: UIScreen.getWidth(114),
                height: UIScreen.getHeight(36))
          }
          .frame(width: UIScreen.getWidth(114), height: UIScreen.getHeight(36))
          .padding(.bottom, UIScreen.getHeight(24))
          .buttonStyle(ProfileEditButtonStyle())
        } else {
          memberFollowBlockButton()
        }
        // Whistle or Follow count
        HStack(spacing: 0) {
          Button {
            goWhistleRanking = true
          } label: {
            VStack(spacing: 4) {
              Text(
                "\(apiViewModel.memberProfile.isBlocked ? 0 : (profileType == .my ? apiViewModel.myWhistleCount : apiViewModel.memberWhistleCount))")
                .foregroundColor(Color.LabelColor_Primary_Dark)
                .fontSystem(fontDesignSystem: .title2_Expanded)
              Text(CommonWords().whistle)
                .foregroundColor(Color.LabelColor_Secondary_Dark)
                .fontSystem(fontDesignSystem: .caption_SemiBold)
            }
            .hCenter()
          }
          Rectangle().frame(width: 1).foregroundColor(.white).scaleEffect(0.5)
          NavigationLink {
            if profileType == .my {
              MyFollowListView()
            } else {
              MemberFollowListView(userName: apiViewModel.memberProfile.userName, userId: userId)
            }
          } label: {
            VStack(spacing: 4) {
              Text("\(apiViewModel.memberProfile.isBlocked ? 0 : filteredFollower.count)")
                .foregroundColor(Color.LabelColor_Primary_Dark)
                .fontSystem(fontDesignSystem: .title2_Expanded)
              Text(CommonWords().follower)
                .foregroundColor(Color.LabelColor_Secondary_Dark)
                .fontSystem(fontDesignSystem: .caption_SemiBold)
            }
            .hCenter()
          }
          .id(UUID())
        }
        .frame(height: UIScreen.getHeight(54))
        .padding(.bottom, UIScreen.getHeight(32))
      }
      .fullScreenCover(isPresented: $showProfileEditView) {
        NavigationView {
          ProfileEditView()
        }
      }
      .frame(height: UIScreen.getHeight(418))
      .frame(maxWidth: .infinity)
    }
  }

  @ViewBuilder
  func listEmptyView() -> some View {
    VStack(spacing: 0) {
      Spacer().frame(height: UIScreen.getHeight(90))
      Text(ContentWords().noUploadedContent).fontSystem(fontDesignSystem: .body1)
        .foregroundColor(.LabelColor_Primary_Dark)
      Button {
        tabbarModel.showVideoCaptureView = true
      } label: {
        Text(ContentWords().goUpload)
          .fontSystem(fontDesignSystem: .subtitle2)
          .foregroundColor(Color.LabelColor_Primary_Dark)
          .frame(width: 142, height: 36)
      }
      .buttonStyle(ProfileEditButtonStyle())
    }
  }

  @ViewBuilder
  func bookmarkEmptyView() -> some View {
    VStack(spacing: 0) {
      Spacer().frame(height: UIScreen.getHeight(90))
      Text(ContentWords().noBookmarkedContent)
        .fontSystem(fontDesignSystem: .body1)
        .foregroundColor(.LabelColor_Primary_Dark)
    }
  }

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

  @ViewBuilder
  func introduceText(text: String) -> some View {
    Text(text)
      .foregroundColor(Color.LabelColor_Secondary_Dark)
      .fontSystem(fontDesignSystem: .body2)
      .lineLimit(2)
      .truncationMode(.tail)
      .multilineTextAlignment(.center)
      .fixedSize(horizontal: false, vertical: true)
      .frame(height: UIScreen.getHeight(20))
      .padding(.top, text.isEmpty ? 0 : UIScreen.getHeight(16))
      .padding(.bottom, UIScreen.getHeight(16))
      .padding(.bottom, UIScreen.getHeight(8))
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
      Button("") {
        Task {
          if apiViewModel.memberProfile.isFollowed {
            apiViewModel.memberProfile.isFollowed.toggle()
            await apiViewModel.followAction(userID: userId, method: .delete)
            apiViewModel.mainFeed = apiViewModel.mainFeed.map { item in
              let mutableItem = item
              if mutableItem.userId == userId {
                mutableItem.isFollowed = apiViewModel.memberProfile.isFollowed
              }
              return mutableItem
            }
          } else {
            apiViewModel.memberProfile.isFollowed.toggle()
            await apiViewModel.followAction(userID: userId, method: .post)
            apiViewModel.mainFeed = apiViewModel.mainFeed.map { item in
              let mutableItem = item
              if mutableItem.userId == userId {
                mutableItem.isFollowed = apiViewModel.memberProfile.isFollowed
              }
              return mutableItem
            }
          }
        }
      }
      .buttonStyle(FollowButtonStyle(isFollowed: $apiViewModel.memberProfile.isFollowed))
      .frame(width: UIScreen.getWidth(114), height: UIScreen.getHeight(36))
      .opacity(isProfileLoaded ? 1 : 0)
      .disabled(userId == apiViewModel.myProfile.userId)
      .padding(.bottom, UIScreen.getHeight(24))
    }
  }

  @ViewBuilder
  func memberBottomSheet() -> some View {
    VStack(spacing: 0) {
      HStack {
        Color.clear.frame(width: 28)
        Spacer()
        Text(CommonWords().more)
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
        bottomSheetPosition = .hidden
        if apiViewModel.memberProfile.isBlocked {
          alertViewModel.linearAlert(
            isRed: true,
            title: "\(apiViewModel.memberProfile.userName) 님을 차단 해제하시겠어요?",
            content: AlertContents().unblock,
            destructiveText: CommonWords().unblock)
          {
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
        } else {
          alertViewModel.linearAlert(
            isRed: true,
            title: "\(apiViewModel.memberProfile.userName) 님을 차단하시겠어요?",
            content: AlertContents().block,
            cancelText: CommonWords().cancel,
            destructiveText: CommonWords().block)
          {
            Task {
              await apiViewModel.blockAction(userID: userId, method: .post)
              BlockList.shared.userIds.append(userId)
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
        }
      } label: {
        bottomSheetRowWithIcon(
          systemName: "nosign",
          text: apiViewModel.memberProfile.isBlocked ? CommonWords().unblockAction : CommonWords().blockAction)
      }
      Rectangle().frame(height: 0.5).padding(.leading, 52).foregroundColor(Color.Border_Default_Dark)
      Button {
        bottomSheetPosition = .hidden
        goReport = true
      } label: {
        bottomSheetRowWithIcon(systemName: "exclamationmark.triangle.fill", text: CommonWords().reportAction)
      }
      Rectangle().frame(height: 0.5).padding(.leading, 52).foregroundColor(Color.Border_Default_Dark)
      Button {
        bottomSheetPosition = .hidden
        let shareURL = URL(
          string: "https://readywhistle.com/profile_uni?id=\(userId)")!
        let activityViewController = UIActivityViewController(activityItems: [shareURL], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(
          activityViewController,
          animated: true,
          completion: nil)
      } label: {
        bottomSheetRowWithIcon(systemName: "square.and.arrow.up", text: CommonWords().shareProfile)
      }
      Spacer()
    }
    .frame(height: 298)
  }

  @ViewBuilder
  func myBottomSheet() -> some View {
    VStack(spacing: 0) {
      HStack {
        Color.clear.frame(width: 28)
        Spacer()
        Text(CommonWords().more)
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
        bottomSheetRowWithIcon(systemName: "bell.fill", text: CommonWords().setNotification)
      }
      Rectangle().frame(height: 0.5).padding(.leading, 52).foregroundColor(Color.Border_Default_Dark)
      Button {
        bottomSheetPosition = .hidden
        goMyTeamSelect = true
      } label: {
        bottomSheetRowWithIcon(systemName: "person.badge.shield.checkmark.fill", text: ProfileEditWords().myTeamSelect)
      }
      Rectangle().frame(height: 0.5).padding(.leading, 52).foregroundColor(Color.Border_Default_Dark)
      Button {
        bottomSheetPosition = .hidden
        goMyTeamSkinSelect = true
      } label: {
        bottomSheetRowWithIcon(systemName: "wand.and.stars", text: ProfileEditWords().myTeamSkinSelect)
      }
      Rectangle().frame(height: 0.5).padding(.leading, 52).foregroundColor(Color.Border_Default_Dark)

      Button {
        goLegalInfo = true
      } label: {
        bottomSheetRowWithIcon(systemName: "info.circle.fill", text: CommonWords().about)
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
      Button {
        goGuideStatus = true
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
            tabbarModel.tabSelection = .main
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
    .frame(height: 578)
  }

  @ViewBuilder
  func profileDefaultBackground() -> some View {
    Color.clear.overlay {
      if let url = profileUrl, !url.isEmpty {
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

extension ProfileView {
  var filteredFollower: [FollowerData] {
    if profileType == .my {
      apiViewModel.myFollow.followerList.filter { !BlockList.shared.userIds.contains($0.followerId) }
    } else {
      apiViewModel.memberFollow.followerList.filter { !BlockList.shared.userIds.contains($0.followerId) }
    }
  }
}
