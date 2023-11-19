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
  @AppStorage("isMyTeamLabelOn") var isMyTeamLabelOn = false
  @AppStorage("isMyTeamBackgroundOn") var isMyTeamBackgroundOn = false
  @Environment(\.dismiss) var dismiss
  @StateObject var userAuth = UserAuth.shared
  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject var tabbarModel = TabbarModel.shared
  @StateObject var toastViewModel = ToastViewModel.shared
  @StateObject var alertViewModel = AlertViewModel.shared
  @StateObject var feedPlayersViewModel = MainFeedPlayersViewModel.shared

  @State var bottomSheetPosition: BottomSheetPosition = .hidden
  @State var showProfileEditView = false
  @State var goMyTeamSelect = false
  @State var goMyTeamSkinSelect = false
  @State var goNotiSetting = false
  @State var goLegalInfo = false
  @State var goGuideStatus = false
  @State var goWhistleRanking = false
  @State var tabSelection: profileTabCase = .myVideo
  @State var profileType: ProfileType = .my
  @State var offsetY: CGFloat = 0
  @State var isProfileLoaded = false
  @State var isFirstStack = false
  @State var goReport = false

  @State var isProfileScrolled = false

  @GestureState private var dragOffset = CGSize.zero
  @Binding var isFirstProfileLoaded: Bool
  let processor = BlurImageProcessor(blurRadius: 10)
  let center = UNUserNotificationCenter.current()
  let userId: Int

  var profileUrl: String? {
    profileType == .my ? apiViewModel.myProfile.profileImage : apiViewModel.memberProfile.profileImg
  }

  var body: some View {
    ZStack {
      navigationLinks()
      if bottomSheetPosition != .hidden {
        DimsThick().zIndex(1000)
      }
      if profileType == .my {
        if let myTeam = apiViewModel.myProfile.myTeam, isMyTeamBackgroundOn {
          MyTeamType.teamGradient(myTeam)
        } else {
          profileDefaultBackground()
        }
      } else {
        if let myTeam = apiViewModel.memberProfile.myTeam, isMyTeamBackgroundOn {
          MyTeamType.teamGradient(myTeam)
        } else {
          profileDefaultBackground()
        }
      }
      ScrollView {
        VStack(spacing: 0) {
          if UIDevice.current.userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1334: // iPhone SE 3rd generation
              Spacer().frame(height: 20 * 2)
            default:
              Spacer().frame(height: 64)
            }
          }
          // 프로필 카드
          if offsetY <= -UIScreen.getHeight(339) {
            ZStack {
              glassMorphicView(cornerRadius: 0)
              Text(
                profileType == .my
                  ? apiViewModel.myProfile.userName
                  : apiViewModel.memberProfile.userName)
                .foregroundColor(Color.LabelColor_Primary_Dark)
                .fontSystem(fontDesignSystem: .title2_Expanded)
            }
            .frame(height: profileType == .my ? 177 : 142)
            .ignoresSafeArea()
            .padding(.bottom, 12)
            .offset(y: -offsetY - 64)
            .zIndex(2)
          } else {
            profileCardLayer()
              .background {
                glassProfile(
                  cornerRadius: 32)
              }
              .padding(.horizontal, 16)
              .padding(.bottom, 12)
          }
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
              .offset(y: offsetY <= -UIScreen.getHeight(339) ? -offsetY - 42 - 64 - 16 : 0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .zIndex(3)
          }
          if profileType == .my {
            switch (tabSelection, apiViewModel.myFeed.isEmpty, apiViewModel.bookmark.isEmpty) {
            // 내 비디오 탭 & 올린 컨텐츠 있음
            case (.myVideo, false, _):
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
                      whistleCount: content.whistleCount)
                  }
                  .id(UUID())
                }
              }
              .zIndex(0)
              .offset(y: offsetY <= -UIScreen.getHeight(339) ? UIScreen.getHeight(339) - 42 - 64 : 12)
              .padding(.top, 12)
              .padding(.horizontal, 16)

            // O 탭 & 올린 컨텐츠 있음
            case (.bookmark, _, false):
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
              .zIndex(0)
              .offset(y: offsetY <= -UIScreen.getHeight(339) ? UIScreen.getHeight(339) - 42 - 64 : 12)
              .padding(.top, 20)
              .padding(.horizontal, 16)
            // 내 비디오 탭 & 올린 컨텐츠 없음
            case (.myVideo, true, _):
              listEmptyView()
                .zIndex(0)
                .padding(.horizontal, 16)
            // 북마크 탭 & 올린 컨텐츠 없음
            case (.bookmark, _, true):
              bookmarkEmptyView()
                .padding(.horizontal, 16)
            }
          } else {
            if apiViewModel.memberFeed.isEmpty {
              if !apiViewModel.memberProfile.isBlocked {
                Spacer().frame(height: UIScreen.getHeight(90))
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
                Spacer().frame(height: UIScreen.getHeight(90))
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
                      whistleCount: content.whistleCount,
                      isHated: content.isHated)
                  }
                  .id(UUID())
                }
              }
              .zIndex(0)
              .offset(y: offsetY <= -UIScreen.getHeight(339) ? UIScreen.getHeight(339) - 42 - 64 : 0)
              .padding(.top, 20)
              .padding(.horizontal, 16)
            }
          }
        }
        .ignoresSafeArea()
        .offset(coordinateSpace: .named("SCROLL")) { offset in
          offsetY = offset
        }
        if profileType == .my {
          if !apiViewModel.myFeed.isEmpty, tabSelection == .myVideo {
            Spacer().frame(height: 1000)
          }
          if !apiViewModel.bookmark.isEmpty, tabSelection == .bookmark {
            Spacer().frame(height: 1000)
          }
        } else {
          if !apiViewModel.memberFeed.isEmpty {
            Spacer().frame(height: 1000)
          }
        }
      }
      .ignoresSafeArea()
      .scrollIndicators(.hidden)
      .coordinateSpace(name: "SCROLL")
      .zIndex(0)
      .refreshable {
        HapticManager.instance.impact(style: .medium)
        if profileType == .my {
          Task {
            await apiViewModel.requestMyProfile()
          }
          Task {
            await apiViewModel.requestMyFollow()
          }
          Task {
            await apiViewModel.requestMyWhistlesCount()
          }
          Task {
            await apiViewModel.requestMyPostFeed()
          }
          Task {
            await apiViewModel.requestMyBookmark()
          }
        } else {
          Task {
            await apiViewModel.requestMemberProfile(userID: userId)
          }
          Task {
            await apiViewModel.requestMemberFollow(userID: userId)
          }
          Task {
            await apiViewModel.requestMemberWhistlesCount(userID: userId)
          }
          Task {
            await apiViewModel.requestMemberPostFeed(userID: userId)
          }
        }
      }
    }
    .navigationBarBackButtonHidden()
    .ignoresSafeArea()
    .overlay {
      VStack(spacing: 0) {
        HStack {
          if profileType == .my, isFirstStack {
            NavigationLink {
              NotificationListView()
            } label: {
              Image(systemName: "bell")
                .foregroundColor(.white)
                .fontWeight(.semibold)
                .frame(width: 48, height: 48)
                .background(
                  Circle()
                    .foregroundColor(.Gray_Default)
                    .frame(width: 48, height: 48))
            }
            .id(UUID())
            .padding(.horizontal, 16)
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
            .padding(.horizontal, 16)
          }

          Spacer()
          Button {
            withAnimation {
              bottomSheetPosition = .dynamic
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
          .padding(.horizontal, 16)
        }
        Spacer()
      }
      .padding(16)
      .padding(.top, 16)
      .offset(y: offsetY > 0 ? offsetY : 0)
    }
    .gesture(DragGesture().updating($dragOffset) { value, _, _ in
      if value.startLocation.x < 30, value.translation.width > 100 {
        dismiss()
      }
    })
    .fullScreenCover(isPresented: $goReport) {
      ProfileReportTypeSelectionView(goReport: $goReport, userId: userId)
        .environmentObject(apiViewModel)
    }
    .task {
      if profileType == .my {
        if isFirstProfileLoaded {
          //          await apiViewModel.requestMyProfile()
          isProfileLoaded = true
          await apiViewModel.requestMyFollow()
          await apiViewModel.requestMyWhistlesCount()
          await apiViewModel.requestMyBookmark()
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
    .bottomSheet(
      bottomSheetPosition: $bottomSheetPosition,
      switchablePositions: [.hidden, .dynamic])
    {
      if profileType == .my {
        myBottomSheet()
      } else {
        memberBottomSheet()
      }
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
    .onChange(of: apiViewModel.memberProfile.isBlocked) { _ in
      offsetY = 0
    }
  }
}

// MARK: - ProfileType

enum ProfileType {
  case my
  case member
}

extension ProfileView {
  @ViewBuilder
  func teamp() -> some View {
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
                    whistleCount: content.whistleCount)
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
                    whistleCount: content.whistleCount,
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
}
