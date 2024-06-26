//
//  RootTabView.swift
//  Whistle
//
//  Created by ChoiYujin on 8/30/23.
//

import _AuthenticationServices_SwiftUI
import BottomSheet
import Combine
import GoogleSignIn
import KeychainSwift
import Mixpanel
import Photos
import SwiftUI
import VideoPicker

// MARK: - RootTabView

struct RootTabView: View {
  @AppStorage("showGuide") var showGuide = true
  @AppStorage("isAccess") var isAccess = false
  @AppStorage("isMyTeamSelectPassed") var isMyTeamSelectPassed = false
  @AppStorage("isMyTeamLabelOn") var isMyTeamLabelOn = true
  @AppStorage("isMyTeamBackgroundOn") var isMyTeamBackgroundOn = true
  @AppStorage("isMyTeamSelected") var isMyTeamSelected = false

  @State var isFirstProfileLoaded = true
  @State var mainOpacity = 1.0
  @State var isRootStacked = false
  @State var refreshCount = 0

  @State private var albumAuthorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
  @State private var videoAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
  @State private var microphoneAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .audio)
  // upload
  @State var isAlbumAuthorized = false
  @State var isCameraAuthorized = false
  @State var isMicrophoneAuthorized = false
  @State var isNavigationActive = true
  @State var showTermsOfService = false
  @State var showPrivacyPolicy = false

  @State private var uploadBottomSheetPosition: BottomSheetPosition = .hidden
  @State private var pickerOptions = PickerOptionsInfo()
  @StateObject private var feedPlayersViewModel = MainFeedPlayersViewModel.shared
  @StateObject private var tabbarModel = TabbarModel.shared
  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject var alertViewModel = AlertViewModel.shared
  @StateObject var toastViewModel = ToastViewModel.shared
  @StateObject var userAuth = UserAuth.shared
  @StateObject var bartintModel = BarTintModel.shared
  @EnvironmentObject var universalRoutingModel: UniversalRoutingModel
  @StateObject var appleSignInViewModel = AppleSignInViewModel()
  let keychain = KeychainSwift()

  var body: some View {
    ZStack {
      if !LaunchScreenViewModel.shared.displayLaunchScreen {
        guideView
      }
      TabView(selection: $tabbarModel.tabSelection) {
        if isAccess {
          NavigationStack {
            if
              !isMyTeamSelectPassed,
              apiViewModel.myProfile.myTeam == nil,
              !apiViewModel.myProfile.userName.isEmpty
            {
              MyTeamSelectView()
                .tag(TabSelection.main)
            } else {
              ZStack {
                if LaunchScreenViewModel.shared.displayLaunchScreen {
                  SignInPlayer()
                    .ignoresSafeArea()
                    .allowsTightening(false)
                    .zIndex(200)
                }
                MainFeedView()
                  .environmentObject(universalRoutingModel)
              }
              .tag(TabSelection.main)
            }
          }
        } else {
          ZStack {
            if LaunchScreenViewModel.shared.displayLaunchScreen {
              SignInPlayer()
                .ignoresSafeArea()
                .allowsTightening(false)
                .zIndex(200)
            }
            GuestMainFeedView()
              .onChange(of: tabbarModel.tabSelection) { newValue in
                mainOpacity = newValue == .main ? 1 : 0
              }
          }
          .tag(TabSelection.main)
        }

        if isAccess {
          // MARK: - profile

          NavigationStack {
            ProfileView(isFirstStack: true, isFirstProfileLoaded: $isFirstProfileLoaded, userId: 0)
          }
          .tag(TabSelection.profile)
        } else {
          GuestProfileView()
            .tag(TabSelection.profile)
        }
      }
      .background(.backgroundDefault)
      .tint(bartintModel.tintColor)
      .ignoresSafeArea()
      if !toastViewModel.onFullScreenCover {
        ToastMessageView()
          .zIndex(9)
      }

      // MARK: - Tabbar
      if !LaunchScreenViewModel.shared.displayLaunchScreen {
        VStack {
          Spacer()
          glassMorphicTab(width: tabbarModel.tabWidth)
            .overlay {
              if !tabbarModel.isCollpased() {
                tabItems()
              } else {
                HStack(spacing: 0) {
                  Spacer().frame(minWidth: 0)
                  Circle()
                    .foregroundColor(.Dim_Default)
                    .frame(width: 48, height: 48)
                    .overlay {
                      Circle()
                        .stroke(lineWidth: 1)
                        .foregroundStyle(LinearGradient.Border_Glass)
                    }
                    .padding(4)
                    .overlay {
                      Image(systemName: "arrow.left.and.right")
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                    }
                    .gesture(
                      DragGesture(minimumDistance: 0, coordinateSpace: .local).onEnded { _ in
                        tabbarModel.expand()
                      })
                }
              }
            }
            .gesture(
              DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onEnded { value in
                  if value.translation.width > 50 {
                    tabbarModel.collapse()
                  }
                })
        }
        .zIndex(10)
        .padding(.bottom, 24)
        .ignoresSafeArea()
        .opacity(showGuide ? 0.0 : tabbarModel.tabbarOpacity)
        .padding(.horizontal, 16)
        .onReceive(NavigationModel.shared.$navigate, perform: { _ in
          if UploadProgress.shared.isUploading {
            tabbarModel.switchTab(to: .main)
            tabbarModel.showVideoCaptureView = false
          }
        })
      }
    }
    .onAppear {
      UITabBar.appearance().isHidden = true
    }
    .overlay {
      if !alertViewModel.onFullScreenCover {
        AlertPopup()
      }
    }
    .fullScreenCover(isPresented: $tabbarModel.showVideoCaptureView) {
      CameraOrAccessView(
        isCam: $isCameraAuthorized,
        isMic: $isMicrophoneAuthorized,
        isNav: $isNavigationActive)
    }
    .bottomSheet(
      bottomSheetPosition: $uploadBottomSheetPosition,
      switchablePositions: [.hidden, .absolute(UIScreen.height - 68)])
    {
      VStack(spacing: 0) {
        HStack {
          Button {
            uploadBottomSheetPosition = .hidden
          } label: {
            Image(systemName: "xmark")
              .foregroundColor(.white)
              .frame(width: 18, height: 18)
              .padding(.horizontal, 16)
          }
          Spacer()
        }
        .frame(height: 52)
        .padding(.bottom, 56)
        Group {
          Text("Whistle")
            .font(.system(size: 24, weight: .semibold)) +
            Text("에 로그인")
            .font(.custom("AppleSDGothicNeo-SemiBold", size: 24))
        }
        .fontWidth(.expanded)
        .lineSpacing(8)
        .padding(.vertical, 4)
        .padding(.bottom, 12)
        .foregroundColor(.LabelColor_Primary_Dark)

        Text("더 많은 스포츠 콘텐츠를 즐겨보세요")
          .fontSystem(fontDesignSystem: .body1)
          .foregroundColor(.LabelColor_Secondary_Dark)
        Spacer()
        Button {
          handleSignInButton()
        } label: {
          Capsule()
            .foregroundColor(.white)
            .frame(maxWidth: 360, maxHeight: 48)
            .overlay {
              HStack(alignment: .center) {
                Image("GoogleLogo")
                  .resizable()
                  .scaledToFit()
                  .frame(width: 18, height: 18)
                Spacer()
                Text("Google로 계속하기")
                  .font(.custom("Roboto-Medium", size: 16))
                  .fontWeight(.semibold)
                  .foregroundColor(.black.opacity(0.54))
                Spacer()
                Color.clear
                  .frame(width: 18, height: 18)
              }
              .padding(.horizontal, 24)
            }
            .padding(.bottom, 16)
        }

        SignInWithAppleButton(
          onRequest: appleSignInViewModel.configureRequest,
          onCompletion: appleSignInViewModel.handleResult)
          .frame(maxWidth: 360, maxHeight: 48)
          .cornerRadius(48)
          .overlay {
            Capsule()
              .foregroundColor(.black)
              .frame(maxWidth: 360, maxHeight: 48)
              .overlay {
                HStack(alignment: .center) {
                  Image(systemName: "apple.logo")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: 18, height: 18)
                  Spacer()
                  Text("Apple로 계속하기")
                    .font(.system(size: 16))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                  Spacer()
                  Color.clear
                    .frame(width: 18, height: 18)
                }
                .padding(.horizontal, 24)
              }
              .allowsHitTesting(false)
          }
          .padding(.bottom, 24)
        Text("가입을 진행할 경우, 아래의 정책에 대해 동의한 것으로 간주합니다.")
          .fontSystem(fontDesignSystem: .caption_Regular)
          .foregroundColor(.LabelColor_Primary_Dark)
        HStack(spacing: 16) {
          Button {
            showTermsOfService = true
          } label: {
            Text("이용약관")
              .underline(true, color: .LabelColor_Primary_Dark)
              .fontSystem(fontDesignSystem: .caption_SemiBold)
          }
          Button {
            showPrivacyPolicy = true
          } label: {
            Text("개인정보처리방침")
              .underline(true, color: .LabelColor_Primary_Dark)
              .fontSystem(fontDesignSystem: .caption_SemiBold)
          }
        }
        .foregroundColor(.LabelColor_Primary_Dark)
        .padding(.bottom, 64)
      }
      .frame(height: UIScreen.height - 68)
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
        })
    .onDismiss {
      tabbarModel.showTabbar()
    }
    .onChange(of: uploadBottomSheetPosition) { newValue in
      if newValue == .hidden {
        tabbarModel.showTabbar()
      } else {
        tabbarModel.hideTabbar()
      }
    }
    .navigationDestination(isPresented: $showTermsOfService) {
      TermsOfServiceView()
    }
    .navigationDestination(isPresented: $showPrivacyPolicy) {
      PrivacyPolicyView()
    }
    .navigationBarBackButtonHidden()
    .onChange(of: tabbarModel.tabSelection) { _ in
      apiViewModel.publisherSend()
    }
  }
}

#Preview {
  RootTabView()
}

extension RootTabView {
  @ViewBuilder
  func tabItems() -> some View {
    HStack(spacing: 0) {
      Button {
        if tabbarModel.tabSelection == .main {
          if isAccess {
            HapticManager.instance.impact(style: .medium)
            NavigationUtil.popToRootView()
          }
        } else {
          tabbarModel.switchTab(to: .main)
        }
      } label: {
        VStack {
          Image(systemName: tabbarModel.tabSelection == .main ? "play.square.fill" : "play.square")
            .font(.system(size: 19))
          Text(CommonWords().play)
            .fontSystem(fontDesignSystem: .caption2_Regular)
        }
        .hCenter()
        .padding(.leading, 4)
      }
      Button {
        getCameraPermission()
        getMicrophonePermission()
        checkAllPermissions()
        tabbarModel.showVideoCaptureView = true
      } label: {
        Capsule()
          .fill(Color.Dim_Thin)
          .overlay {
            Capsule().strokeBorder(LinearGradient.Border_Glass)
            Image(systemName: "plus")
              .font(.system(size: 20))
          }
      }
      .frame(width: UIScreen.getWidth(80), height: UIScreen.getHeight(40))
      .padding(.horizontal, 8)
      Button {
        profileTabClicked()
      } label: {
        VStack {
          Image(systemName: tabbarModel.tabSelection == .profile ? "person.fill" : "person")
            .font(.system(size: 19))
          Text(CommonWords().profile)
            .fontSystem(fontDesignSystem: .caption2_Regular)
        }
        .hCenter()
        .padding(.trailing, 4)
      }
    }
    .foregroundColor(.white)
    .frame(height: UIScreen.getHeight(56))
    .frame(maxWidth: .infinity)
  }

  @ViewBuilder
  var guideView: some View {
    if showGuide {
      ZStack {
        Color.clear.overlay {
          Image("gestureGuide")
            .resizable()
            .scaledToFill()
        }
        VStack {
          Spacer()
          Button {
            Mixpanel.mainInstance().track(event: "onboarding_complete")
            showGuide = false
          } label: {
            Text(CommonWords().close)
              .fontSystem(fontDesignSystem: .subtitle2)
              .foregroundColor(Color.LabelColor_Primary_Dark)
              .frame(width: UIScreen.width - 32, height: 56)
              .background {
                glassMorphicView(cornerRadius: 12)
                  .overlay {
                    RoundedRectangle(cornerRadius: 12)
                      .stroke(lineWidth: 1)
                      .foregroundStyle(
                        LinearGradient.Border_Glass)
                  }
              }
          }
          .padding(.bottom, 32)
        }
      }
      .ignoresSafeArea()
      .frame(width: UIScreen.width, height: UIScreen.height)
      .onAppear {
        tabbarModel.hideTabbar()
      }
      .onDisappear {
        tabbarModel.showTabbar()
      }
      .zIndex(100)
    }
  }
}

// MARK: - TabClicked Actions

extension RootTabView {
  var profileTabClicked: () -> Void {
    {
      if tabbarModel.tabSelection == .profile {
        if isAccess {
          HapticManager.instance.impact(style: .medium)
          NavigationUtil.popToRootView()
        }
        Task {
          await apiViewModel.requestMyFollow()
        }
        Task {
          await apiViewModel.requestMyWhistlesCount()
        }
        Task {
          await apiViewModel.requestMyBookmark()
        }
        Task {
          await apiViewModel.requestMyPostFeed()
        }
        isFirstProfileLoaded = false
      } else {
        tabbarModel.switchTab(to: .profile)
      }
    }
  }
}

// MARK: - TabSelection

public enum TabSelection: CGFloat {
  case main = -1.0
  case profile = 1.0
}

// MARK: - 권한

extension RootTabView {
  private func getCameraPermission() {
    let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    switch authorizationStatus {
    case .authorized:
      isCameraAuthorized = true
    default:
      break
    }
  }

  private func getMicrophonePermission() {
    let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .audio)
    switch authorizationStatus {
    case .authorized:
      isMicrophoneAuthorized = true
    default:
      break
    }
  }

  private func requestCameraPermission() {
    AVCaptureDevice.requestAccess(for: .video) { granted in
      DispatchQueue.main.async {
        isCameraAuthorized = granted
        checkAllPermissions()
      }
    }
  }

  private func requestMicrophonePermission() {
    AVCaptureDevice.requestAccess(for: .audio) { granted in
      DispatchQueue.main.async {
        isMicrophoneAuthorized = granted
        checkAllPermissions()
      }
    }
  }

  private func checkAllPermissions() {
    if isCameraAuthorized, isMicrophoneAuthorized {
      isNavigationActive = true
    } else {
      isNavigationActive = false
    }
  }
}
