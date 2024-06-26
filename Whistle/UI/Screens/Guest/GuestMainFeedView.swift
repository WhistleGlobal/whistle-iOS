//
//  GuestMainFeedView.swift
//  Whistle
//
//  Created by ChoiYujin on 11/1/23.
//

import _AuthenticationServices_SwiftUI
import _AVKit_SwiftUI
import BottomSheet
import Mixpanel
import SwiftUI

// MARK: - GuestMainFeedView

struct GuestMainFeedView: View {
  @StateObject private var apiViewModel = APIViewModel.shared
  @StateObject var appleSignInViewModel = AppleSignInViewModel()
  @StateObject private var feedPlayersViewModel = GuestFeedPlayersViewModel.shared
  @StateObject private var toastViewModel = ToastViewModel.shared
  @StateObject private var feedMoreModel = GuestMainFeedMoreModel.shared
  @StateObject private var tabbarModel = TabbarModel.shared
  @State var showTermsOfService = false
  @State var showPrivacyPolicy = false
  @State var index = 0

  var body: some View {
    ZStack {
      Color.black
      if !apiViewModel.guestFeed.isEmpty {
        GuestMainFeedPageView(index: $index)
      }
    }
    .background(Color.black.edgesIgnoringSafeArea(.all))
    .edgesIgnoringSafeArea(.all)
    .navigationDestination(isPresented: $showTermsOfService) {
      TermsOfServiceView()
    }
    .navigationDestination(isPresented: $showPrivacyPolicy) {
      PrivacyPolicyView()
    }
    .bottomSheet(
      bottomSheetPosition: $feedMoreModel.bottomSheetPosition,
      switchablePositions: [.hidden, .dynamic])
    {
      VStack(spacing: 0) {
        HStack {
          Spacer()
          Button {
            tabbarModel.showTabbar()
            feedMoreModel.bottomSheetPosition = .hidden
          } label: {
            Text(CommonWords().cancel)
              .fontSystem(fontDesignSystem: .subtitle2)
              .foregroundColor(.white)
              .padding(.horizontal, 16)
          }
        }
        .frame(height: 52)
        .padding(.bottom, 36)
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
      .frame(height: UIScreen.height * 0.7)
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
    .onChange(of: feedMoreModel.bottomSheetPosition) { newValue in
      if newValue == .hidden {
        tabbarModel.showTabbar()
      } else {
        tabbarModel.hideTabbar()
      }
    }
    .task {
      let updateAvailable = await apiViewModel.checkUpdateAvailable()
      if updateAvailable {
        await apiViewModel.requestVersionCheck()
        feedMoreModel.showUpdate = apiViewModel.versionCheck.forceUpdate
        if feedMoreModel.showUpdate {
          return
        }
      }
      if apiViewModel.myProfile.userName.isEmpty {
        await apiViewModel.requestMyProfile()
      }
      if apiViewModel.guestFeed.isEmpty {
        apiViewModel.requestGuestFeed { value in
          switch value.result {
          case .success:
            LaunchScreenViewModel.shared.feedDownloaded()
          case .failure:
            WhistleLogger.logger.debug("MainFeed Download Failure")
            apiViewModel.requestGuestFeed { _ in }
          }
        }
      }
    }
    .onAppear {
      Mixpanel.mainInstance().track(event: "login", properties: [
        "did_login": false,
      ])
    }
    .overlay(alignment: .top) {
      HStack {
        Spacer()
        Text("마이팀")
          .fontSystem(fontDesignSystem: .subtitle2)
          .onTapGesture {
            feedMoreModel.bottomSheetPosition = .dynamic
          }
        Rectangle()
          .fill(Color.white)
          .frame(width: 1, height: 12)
        Text("전체")
          .fontSystem(fontDesignSystem: .subtitle2)
          .scaleEffect(1.1)
        Spacer()
      }
      .foregroundColor(.white)
      .overlay(alignment: .trailing) {
        NavigationLink {
          MainSearchView()
        } label: {
          Image(systemName: "magnifyingglass")
            .font(.system(size: 24))
            .foregroundStyle(Color.white)
        }
        .id(UUID())
      }
      .padding(.horizontal, 16)
      .padding(.top, 54)
      .ignoresSafeArea()
    }
  }
}

// MARK: - GuestMainFeedMoreModel

class GuestMainFeedMoreModel: ObservableObject {
  static let shared = GuestMainFeedMoreModel()
  private init() { }
  @Published var showReport = false
  @Published var showUpdate = false
  @Published var isRootStacked = false
  @Published var bottomSheetPosition: BottomSheetPosition = .hidden
}
