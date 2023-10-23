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
import Photos
import SwiftUI
import VideoPicker

// MARK: - RootTabView

struct RootTabView: View {
  @AppStorage("showGuide") var showGuide = true

  @State var isFirstProfileLoaded = true
  @State var mainOpacity = 1.0
  @State var isRootStacked = false

  @State var refreshCount = 0

  @State private var albumAuthorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
  @State private var videoAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
  @State private var microphoneAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .audio)
  // upload
  @State private var isAlbumAuthorized = false
  @State private var isCameraAuthorized = false
  @State private var isMicrophoneAuthorized = false
  @State private var isNavigationActive = true
  @State var showTermsOfService = false
  @State var showPrivacyPolicy = false

  @State private var uploadBottomSheetPosition: BottomSheetPosition = .hidden
  @State private var pickerOptions = PickerOptionsInfo()
  @AppStorage("isAccess") var isAccess = false
  @StateObject private var tabbarModel = TabbarModel.shared
  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject var userAuth = UserAuth.shared
  @EnvironmentObject var universalRoutingModel: UniversalRoutingModel
  @StateObject var appleSignInViewModel = AppleSignInViewModel()

  let keychain = KeychainSwift()

  var body: some View {
    ZStack {
      if isAccess {
        NavigationStack {
          MainFeedView(
            mainOpacity: $mainOpacity,
            isRootStacked: $isRootStacked,
            refreshCount: $refreshCount)

            .environmentObject(universalRoutingModel)
            .opacity(mainOpacity)
            .onChange(of: tabbarModel.tabSelectionNoAnimation) { newValue in
              mainOpacity = newValue == .main ? 1 : 0
            }
        }
        .tint(.black)
      } else {
        GuestMainView(mainOpacity: $mainOpacity)
          .opacity(mainOpacity)
          .onChange(of: tabbarModel.tabSelectionNoAnimation) { newValue in
            mainOpacity = newValue == .main ? 1 : 0
          }
      }

      switch tabbarModel.tabSelectionNoAnimation {
      case .main:
        Color.clear

      case .upload:
        NavigationView {
          if isCameraAuthorized, isMicrophoneAuthorized {
            VideoCaptureView()

          } else {
            if !isNavigationActive {
              RecordAccessView(
                isCameraAuthorized: $isCameraAuthorized,
                isMicrophoneAuthorized: $isMicrophoneAuthorized)
            }
          }
        }
        .onAppear {
          getCameraPermission()
          getMicrophonePermission()
          checkAllPermissions()
          tabbarModel.tabbarOpacity = 0.0
        }
        .onDisappear {
          tabbarModel.tabbarOpacity = 1.0
        }

      case .profile:
        if isAccess {
          NavigationStack {
            if UIDevice.current.userInterfaceIdiom == .phone {
              switch UIScreen.main.nativeBounds.height {
              case 1334: // iPhone SE 3rd generation
                SEMyProfileView(isFirstProfileLoaded: $isFirstProfileLoaded)
              default:
                MyProfileView(isFirstProfileLoaded: $isFirstProfileLoaded)
              }
            }
          }
          .tint(.black)
        } else {
          GuestProfileView()
        }
      }
      VStack {
        Spacer()
        glassMorphicTab(width: tabbarModel.tabWidth)
          .overlay {
            if tabbarModel.tabWidth != 56 {
              tabItems()
            } else {
              HStack(spacing: 0) {
                Spacer().frame(minWidth: 0)
                Button {
                  withAnimation {
                    tabbarModel.tabWidth = UIScreen.width - 32
                  }
                } label: {
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
                      Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .foregroundColor(.White)
                        .frame(width: 20, height: 20)
                    }
                }
              }
            }
          }
          .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
              .onEnded { value in
                if value.translation.width > 50 {
                  withAnimation {
                    tabbarModel.tabWidth = 56
                  }
                }
              })
      }
      .padding(.bottom, 20)
      .ignoresSafeArea()
      .padding(.horizontal, 16)
      .opacity(showGuide ? 0.0 : tabbarModel.tabbarOpacity)
      .onReceive(NavigationModel.shared.$navigate, perform: { _ in
        if tabbarModel.tabSelection == .upload {
          if UploadProgressViewModel.shared.isUploading {
            tabbarModel.tabSelection = .main
            tabbarModel.tabSelectionNoAnimation = .main
          } else {
            tabbarModel.tabSelection = tabbarModel.prevTabSelection ?? .main
            tabbarModel.tabSelectionNoAnimation = tabbarModel.prevTabSelection ?? .main
          }
        }
      })
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
              .foregroundColor(.White)
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
          .fontSystem(fontDesignSystem: .body1_KO)
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
          .fontSystem(fontDesignSystem: .caption_KO_Regular)
          .foregroundColor(.LabelColor_Primary_Dark)
        HStack(spacing: 16) {
          Button {
            showTermsOfService = true
          } label: {
            Text("이용약관")
              .font(.system(size: 12, weight: .semibold))
              .underline(true, color: .LabelColor_Primary_Dark)
          }
          Button {
            showPrivacyPolicy = true
          } label: {
            Text("개인정보처리방침")
              .font(.system(size: 12, weight: .semibold))
              .underline(true, color: .LabelColor_Primary_Dark)
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
      glassMorphicView(width: UIScreen.width, height: .infinity, cornerRadius: 24)
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
    .onChange(of: uploadBottomSheetPosition) { newValue in
      if newValue == .hidden {
        tabbarModel.tabbarOpacity = 1.0
      } else {
        tabbarModel.tabbarOpacity = 0.0
      }
    }
    .navigationDestination(isPresented: $showTermsOfService) {
      TermsOfServiceView()
    }
    .navigationDestination(isPresented: $showPrivacyPolicy) {
      PrivacyPolicyView()
    }
    .navigationBarBackButtonHidden()
  }
}

#Preview {
  RootTabView()
}

extension RootTabView {
  @ViewBuilder
  func tabItems() -> some View {
    RoundedRectangle(cornerRadius: 100)
      .foregroundColor(Color.Dim_Default)
      .frame(width: (UIScreen.width - 32) / 3 - 6)
      .offset(x: tabbarModel.tabSelection.rawValue * ((UIScreen.width - 32) / 3))
      .padding(3)
      .overlay {
        Capsule()
          .stroke(lineWidth: 1)
          .foregroundStyle(LinearGradient.Border_Glass)
          .padding(3)
          .offset(x: tabbarModel.tabSelection.rawValue * ((UIScreen.width - 32) / 3))
      }
      .foregroundColor(.clear)
      .frame(height: 56)
      .frame(maxWidth: .infinity)
      .overlay {
        Button {
          if tabbarModel.tabSelectionNoAnimation == .main {
            if isAccess {
              if isRootStacked {
                NavigationUtil.popToRootView()
              } else {
                apiViewModel.requestMainFeed {
                  HapticManager.instance.impact(style: .medium)
                  refreshCount += 1
                }
              }
            }
          } else {
            switchTab(to: .main)
          }
        } label: {
          Color.clear.overlay {
            Image(systemName: "house.fill")
              .resizable()
              .scaledToFit()
              .frame(width: 24, height: 24)
          }
          .frame(width: (UIScreen.width - 32) / 3, height: 56)
        }
        .foregroundColor(.white)
        .padding(3)
        .offset(x: -1 * ((UIScreen.width - 32) / 3))
        Button {
          if isAccess {
            switchTab(to: .upload)
          } else {
            uploadBottomSheetPosition = .relative(1)
          }
        } label: {
          Color.clear.overlay {
            Image(systemName: "plus")
              .resizable()
              .scaledToFit()
              .frame(width: 20, height: 20)
              .foregroundColor(.white)
          }
          .frame(width: (UIScreen.width - 32) / 3, height: 56)
        }
        .foregroundColor(.white)
        .padding(3)
        Button {
          profileTabClicked()
        } label: {
          Color.clear.overlay {
            Image(systemName: "person.fill")
              .resizable()
              .scaledToFit()
              .frame(width: 20, height: 20)
              .foregroundColor(.white)
          }
          .frame(width: (UIScreen.width - 32) / 3, height: 56)
        }
        .foregroundColor(.white)
        .padding(3)
        .offset(x: (UIScreen.width - 32) / 3)
      }
      .frame(height: 56)
      .frame(maxWidth: .infinity)
  }
}

// MARK: - TabClicked Actions

extension RootTabView {
  var profileTabClicked: () -> Void {
    {
      if tabbarModel.tabSelectionNoAnimation == .profile {
        switchTab(to: .profile)
        HapticManager.instance.impact(style: .medium)
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
        switchTab(to: .profile)
        if isFirstProfileLoaded {
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
        }
      }
    }
  }

  func switchTab(to tabSelection: TabSelection) {
    if tabbarModel.prevTabSelection == nil {
      tabbarModel.prevTabSelection = .main
    } else {
      tabbarModel.prevTabSelection = tabbarModel.tabSelectionNoAnimation
    }
    tabbarModel.tabSelectionNoAnimation = tabSelection
    withAnimation {
      tabbarModel.tabSelection = tabSelection
    }
  }
}

// MARK: - TabSelection

public enum TabSelection: CGFloat {
  case main = -1.0
  case upload = 0.0
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
