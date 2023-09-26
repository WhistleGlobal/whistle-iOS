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

// MARK: - ProfileView

struct ProfileView: View {

  // MARK: Public

  public enum profileTabCase: String {
    case myVideo
    case bookmark
  }

  // MARK: Internal

  @State var isShowingBottomSheet = false
  @State var tabbarDirection: CGFloat = -1.0
  @State var tabSelection: profileTabCase = .myVideo
  @State var showSignoutAlert = false
  @State var showDeleteAlert = false
  @State var bottomSheetPosition: BottomSheetPosition = .hidden
  @Binding var isFirstProfileLoaded: Bool
  @EnvironmentObject var apiViewModel: APIViewModel
  @EnvironmentObject var userAuth: UserAuth
  @EnvironmentObject var tabbarModel: TabbarModel

  var body: some View {
    ZStack {
      Color.clear.overlay {
        if let url = apiViewModel.myProfile.profileImage, !url.isEmpty {
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
        Spacer().frame(height: 64)
        glassProfile(
          width: UIScreen.width - 32,
          height: 418,
          cornerRadius: 32,
          overlayed: profileInfo(minHeight: 398, maxHeight: 418))
          .padding(.bottom, 12)
        HStack(spacing: 0) {
          Button {
            tabSelection = .myVideo
          } label: {
            Color.gray
              .opacity(0.01)
              .frame(maxWidth: .infinity, maxHeight: .infinity)
          }
          .buttonStyle(ProfileTabItem(
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
          .buttonStyle(ProfileTabItem(
            systemName: "bookmark.fill",
            tab: profileTabCase.bookmark.rawValue,
            selectedTab: $tabSelection))
        }
        .frame(height: 48)
        .padding(.bottom, 16)
        switch (tabSelection, apiViewModel.myPostFeed.isEmpty, apiViewModel.bookmark.isEmpty) {
        // 내 비디오 탭 & 올린 컨텐츠 있음
        case (.myVideo, false, _):
          ScrollView {
            LazyVGrid(columns: [
              GridItem(.flexible()),
              GridItem(.flexible()),
              GridItem(.flexible()),
            ], spacing: 20) {
              ForEach(Array(apiViewModel.myPostFeed.enumerated()), id: \.element) { index, content in
                NavigationLink {
                  MyContentListView(currentIndex: index)
                    .environmentObject(apiViewModel)
                } label: {
                  videoThumbnailView(thumbnailUrl: content.thumbnailUrl ?? "", viewCount: content.contentViewCount ?? 0)
                }
              }
            }
          }
          Spacer()
        // 북마크 탭 & 올린 컨텐츠 있음
        case (.bookmark, _, false):
          ScrollView {
            LazyVGrid(columns: [
              GridItem(.flexible()),
              GridItem(.flexible()),
              GridItem(.flexible()),
            ], spacing: 20) {
              ForEach(apiViewModel.bookmark, id: \.self) { content in
                Button {
                  log("video clicked")
                } label: {
                  videoThumbnailView(thumbnailUrl: content.thumbnailUrl, viewCount: content.viewCount)
                }
              }
            }
          }
          Spacer()
        // 내 비디오 탭 & 올린 컨텐츠 없음
        case (.myVideo, true, _):
          listEmptyView()
        // 북마크 탭 & 올린 컨텐츠 없음
        case (.bookmark, _, true):
          listEmptyView()
        }
      }
      .padding(.horizontal, 16)
      .ignoresSafeArea()
      VStack {
        Spacer()
        GlassBottomSheet(
          isShowing: $isShowingBottomSheet,
          showSignoutAlert: $showSignoutAlert,
          showDeleteAlert: $showDeleteAlert,
          content: AnyView(Text("")))
          .environmentObject(apiViewModel)
          .environmentObject(userAuth)
          .onChange(of: isShowingBottomSheet) { newValue in
            if !newValue {
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                tabbarModel.tabbarOpacity = 1
              }
            }
          }
          .gesture(
            DragGesture(minimumDistance: 20, coordinateSpace: .local)
              .onEnded { value in
                if value.translation.height > 20 {
                  withAnimation {
                    isShowingBottomSheet = false
                  }
                  DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    tabbarModel.tabbarOpacity = 1
                  }
                }
              })
      }
      .ignoresSafeArea()
    }
    .overlay {
      if showSignoutAlert {
        SignoutAlert {
          showSignoutAlert = false
        } signOutAction: {
          apiViewModel.myProfile.userName.removeAll()
          GIDSignIn.sharedInstance.signOut()
          userAuth.appleSignout()
          isFirstProfileLoaded = true
        }
      }
      if showDeleteAlert {
        DeleteAccountAlert {
          showDeleteAlert = false
        } deleteAction: {
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
    .onChange(of: bottomSheetPosition) { newValue in
      if newValue == .hidden {
//        tabbarModel.tabbarOpacity = 1.0
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
          ProfileNotiView()
            .environmentObject(apiViewModel)
        } label: {
          bottomSheetRowWithIcon(systemName: "bell", iconWidth: 22, iconHeight: 20, text: "알림")
        }
        NavigationLink {
          ProfileInfoView()
            .environmentObject(apiViewModel)
        } label: {
          bottomSheetRowWithIcon(systemName: "info.circle", iconWidth: 22, iconHeight: 20, text: "약관 및 정책")
        }
        Button {
          withAnimation {
            bottomSheetPosition = .hidden
          }
          log("공유")
        } label: {
          bottomSheetRowWithIcon(systemName: "square.and.arrow.up", iconWidth: 22, iconHeight: 20, text: "프로필 공유")
        }
        NavigationLink {
          ProfileReportView()
            .environmentObject(apiViewModel)
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
      glassMoriphicView(width: UIScreen.width, height: .infinity, cornerRadius: 24)
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
  func profileInfo(minHeight _: CGFloat, maxHeight _: CGFloat) -> some View {
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
                .foregroundColor(Color.White)
                .fontWeight(.semibold)
                .frame(width: 20, height: 20)
            }
        }
      }
      .padding([.top, .horizontal], 16)
      profileImageView(url: apiViewModel.myProfile.profileImage, size: 100)
        .padding(.bottom, 16)
      Text(apiViewModel.myProfile.userName)
        .foregroundColor(Color.LabelColor_Primary_Dark)
        .fontSystem(fontDesignSystem: .title2_Expanded)
        .padding(.bottom, 4)
      Text(apiViewModel.myProfile.introduce ?? " ")
        .foregroundColor(Color.LabelColor_Secondary_Dark)
        .fontSystem(fontDesignSystem: .body2_KO)
        .lineLimit(nil)
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 48)
        .padding(.bottom, 16)
      Spacer()
      NavigationLink {
        ProfileEditView()
          .environmentObject(apiViewModel)
      } label: {
        Text("프로필 편집")
          .fontSystem(fontDesignSystem: .subtitle2_KO)
          .foregroundColor(Color.LabelColor_Primary_Dark)
          .frame(width: 114, height: 36)
      }
      .frame(width: 114, height: 36)
      .padding(.bottom, 24)
      .buttonStyle(ProfileEditButtonStyle())
      HStack(spacing: 48) {
        VStack(spacing: 4) {
          Text("\(apiViewModel.myWhistleCount)")
            .foregroundColor(Color.LabelColor_Primary_Dark)
            .fontSystem(fontDesignSystem: .title2_Expanded)
          Text("whistle")
            .foregroundColor(Color.LabelColor_Secondary_Dark)
            .fontSystem(fontDesignSystem: .caption_SemiBold)
        }
        Rectangle().frame(width: 1, height: 36).foregroundColor(.white)
        NavigationLink {
          FollowView()
            .environmentObject(apiViewModel)
            .environmentObject(tabbarModel)
        } label: {
          VStack(spacing: 4) {
            Text("\(apiViewModel.myFollow.followerCount)")
              .foregroundColor(Color.LabelColor_Primary_Dark)
              .fontSystem(fontDesignSystem: .title2_Expanded)
            Text("follower")
              .foregroundColor(Color.LabelColor_Secondary_Dark)
              .fontSystem(fontDesignSystem: .caption_SemiBold)
          }
        }
      }
      .padding(.bottom, 32)
    }
    .frame(height: 418)
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

  @ViewBuilder
  func listEmptyView() -> some View {
    Spacer()
    Text("공유하고 싶은 첫번째 콘텐츠를 업로드해보세요")
      .fontSystem(fontDesignSystem: .body1_KO)
      .foregroundColor(.LabelColor_Primary_Dark)
    Button {
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

extension ProfileView {

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
