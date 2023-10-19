//
//  TabbarView.swift
//  Whistle
//
//  Created by ChoiYujin on 8/30/23.
//

import Combine
import Photos
import SwiftUI
import VideoPicker

// MARK: - TabbarView

struct TabbarView: View {
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

  @State private var pickerOptions = PickerOptionsInfo()
  @AppStorage("isAccess") var isAccess = false
  @EnvironmentObject var apiViewModel: APIViewModel
  @EnvironmentObject var userAuth: UserAuth
  @EnvironmentObject var universalRoutingModel: UniversalRoutingModel
  @StateObject var tabbarModel: TabbarModel = .init()

  var body: some View {
    ZStack {
      if isAccess {
        NavigationStack {
          MainView(
            mainOpacity: $mainOpacity,
            isRootStacked: $isRootStacked,
            refreshCount: $refreshCount)
            .environmentObject(apiViewModel)
            .environmentObject(tabbarModel)
            .environmentObject(universalRoutingModel)
            .opacity(mainOpacity)
            .onChange(of: tabbarModel.tabSelectionNoAnimation) { newValue in
              mainOpacity = newValue == .main ? 1 : 0
            }
        }
        .tint(.black)
      } else {
        NoSignInMainView(mainOpacity: $mainOpacity)
          .environmentObject(apiViewModel)
          .environmentObject(tabbarModel)
          .environmentObject(userAuth)
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
            VideoContentView()
              .environmentObject(apiViewModel)
              .environmentObject(tabbarModel)
          } else {
            if !isNavigationActive {
              AccessView(
                isCameraAuthorized: $isCameraAuthorized,
                isMicrophoneAuthorized: $isMicrophoneAuthorized)
                .environmentObject(tabbarModel)
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
                SEProfileView(isFirstProfileLoaded: $isFirstProfileLoaded)
                  .environmentObject(apiViewModel)
                  .environmentObject(tabbarModel)
                  .environmentObject(userAuth)
              default:
                ProfileView(isFirstProfileLoaded: $isFirstProfileLoaded)
                  .environmentObject(apiViewModel)
                  .environmentObject(tabbarModel)
                  .environmentObject(userAuth)
              }
            }
          }
          .tint(.black)
        } else {
          NoSignInProfileView()
            .environmentObject(tabbarModel)
            .environmentObject(userAuth)
            .environmentObject(apiViewModel)
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
                  log("right swipe")
                  withAnimation {
                    tabbarModel.tabWidth = 56
                  }
                }
              })
      }
      .padding(.bottom, 24)
      .ignoresSafeArea()
      .padding(.horizontal, 16)
      .opacity(showGuide ? 0.0 : tabbarModel.tabbarOpacity)
      .onReceive(NavigationModel.shared.$navigate, perform: { _ in
        if tabbarModel.tabSelection == .upload {
          tabbarModel.tabSelection = tabbarModel.prevTabSelection ?? .main
          tabbarModel.tabSelectionNoAnimation = tabbarModel.prevTabSelection ?? .main
        }
      })
    }
    .navigationBarBackButtonHidden()
  }
}

#Preview {
  TabbarView()
    .environmentObject(APIViewModel())
    .environmentObject(UserAuth())
}

extension TabbarView {
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
                apiViewModel.requestContentList {
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
          switchTab(to: .upload)
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

extension TabbarView {
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

// MARK: - TabbarModel

class TabbarModel: ObservableObject {
  @Published var tabSelection: TabSelection = .main
  @Published var tabSelectionNoAnimation: TabSelection = .main
  @Published var prevTabSelection: TabSelection?
  @Published var tabbarOpacity = 1.0
  @Published var tabWidth = UIScreen.width - 32
}


// MARK: - 권한
extension TabbarView {

  private func getCameraPermission() {
    let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    switch authorizationStatus {
    case .notDetermined:
      log("notDetermined")
    case .restricted:
      log("restricted")
    case .denied:
      log("restricted")
    case .authorized:
      isCameraAuthorized = true
    @unknown default:
      log("unknown default")
    }
  }

  private func getMicrophonePermission() {
    let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .audio)
    switch authorizationStatus {
    case .notDetermined:
      log("notDetermined")
    case .restricted:
      log("restricted")
    case .denied:
      log("restricted")
    case .authorized:
      isMicrophoneAuthorized = true
    @unknown default:
      log("unknown default")
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
