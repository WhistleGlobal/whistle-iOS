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

  @State var isShowingBottomSheet = false
  @State var tabbarDirection: CGFloat = -1.0
  @State var tabSelection: profileTabCase = .myVideo
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
            .frame(height: 418 + (240 * progress))
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
                  MyFeedView(currentIndex: index)
                } label: {
                  videoThumbnailView(
                    thumbnailURL: content.thumbnailUrl ?? "",
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
                  BookmarkedFeedView(currentIndex: index)
                } label: {
                  videoThumbnailView(thumbnailURL: content.thumbnailUrl, viewCount: content.viewCount)
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
            .foregroundColor(.white)
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
          toastViewModel.toastInit(message: "클립보드에 복사되었어요")
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
            text: "가이드 상태")
        }
        Group {
          Divider().background(Color("Gray10"))
          Button {
            withAnimation {
              bottomSheetPosition = .hidden
            }
            alertViewModel.linearAlert(title: "정말 로그아웃하시겠어요?", cancelText: "취소", destructiveText: "로그아웃") {
              apiViewModel.reset()
              GIDSignIn.sharedInstance.signOut()
              userAuth.appleSignout()
              isFirstProfileLoaded = false
            }
          } label: {
            bottomSheetRow(text: "로그아웃", color: Color.Info)
          }
          Button {
            withAnimation {
              bottomSheetPosition = .hidden
            }
            alertViewModel.linearAlert(
              title: "정말 삭제하시겠어요?",
              content: "삭제하시면 회원님의 모든 정보와 활동 기록이 삭제됩니다. 삭제된 정보는 복구할 수 없으니 신중하게 결정해주세요.",
              cancelText: "취소",
              destructiveText: "삭제")
            {
              Task {
                apiViewModel.myProfile.userName.removeAll()
                await apiViewModel.rebokeAppleToken()
                GIDSignIn.sharedInstance.signOut()
                userAuth.appleSignout()
                isFirstProfileLoaded = true
              }
            }
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

extension MyProfileView {
  @ViewBuilder
  func profileInfo() -> some View {
    VStack(spacing: 0) {
      Spacer().frame(height: 64)
      profileImageView(url: apiViewModel.myProfile.profileImage, size: profileImageSize)
        .padding(.bottom, 16)
      Text(apiViewModel.myProfile.userName)
        .foregroundColor(Color.LabelColor_Primary_Dark)
        .fontSystem(fontDesignSystem: .title2_Expanded)
        .padding(.bottom, 4)
      Spacer()
      Color.clear.overlay {
        Text(apiViewModel.myProfile.introduce ?? "")
          .foregroundColor(Color.LabelColor_Secondary_Dark)
          .fontSystem(fontDesignSystem: .body2_KO)
          .lineLimit(nil)
          .multilineTextAlignment(.center)
          .fixedSize(horizontal: false, vertical: true)
          .scaleEffect(introduceScale)
      }
      .frame(height: introduceHeight)
      .padding(.bottom, 16)
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
      .padding(.bottom, 24)
      .buttonStyle(ProfileEditButtonStyle())
      HStack(spacing: 0) {
        VStack(spacing: 4) {
          Text("\(apiViewModel.myWhistleCount)")
            .foregroundColor(Color.LabelColor_Primary_Dark)
            .fontSystem(fontDesignSystem: .title2_Expanded)
            .scaleEffect(whistleFollowerTextScale)
          Text("휘슬")
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
            Text("팔로워")
              .foregroundColor(Color.LabelColor_Secondary_Dark)
              .fontSystem(fontDesignSystem: .caption_SemiBold)
              .scaleEffect(whistleFollowerTextScale)
          }
          .hCenter()
        }
      }
      .frame(height: whistleFollowerTabHeight)
      .padding(.bottom, 32)
    }
    .frame(height: 418 + (240 * progress))
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
          .offset(y: 64 - topSpacerHeight)
          .padding(.horizontal, 16 - profileHorizontalPadding)
        }
        Spacer()
      }
      .padding(16)
    }
  }

  @ViewBuilder
  func videoThumbnailView(thumbnailURL: String, viewCount: Int) -> some View {
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

extension MyProfileView {
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
