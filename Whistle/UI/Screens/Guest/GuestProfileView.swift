//
//  GuestProfileView.swift
//  Whistle
//
//  Created by ChoiYujin on 10/4/23.
//

import _AuthenticationServices_SwiftUI
import BottomSheet
import GoogleSignIn
import KeychainSwift
import SwiftUI

// MARK: - GuestProfileView

struct GuestProfileView: View {
  @AppStorage("isAccess") var isAccess = false
  @StateObject var userAuth = UserAuth.shared
  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject var appleSignInViewModel = AppleSignInViewModel()
  @StateObject private var tabbarModel = TabbarModel.shared
  @StateObject var guestUploadModel = GuestUploadModel.shared
  @State var bottomSheetPosition: BottomSheetPosition = .hidden
  @State var showTermsOfService = false
  @State var showPrivacyPolicy = false

  let keychain = KeychainSwift()

  var body: some View {
    ZStack {
      Color.clear.overlay {
        Image("BlurredDefaultBG")
          .resizable()
          .scaledToFill()
          .scaleEffect(1.4)
      }
      VStack(spacing: 0) {
        Spacer().frame(height: 64)
        glassProfile(
          cornerRadius: 32,
          overlayed: overlayedView())
          .frame(height: 340)
          .padding(.horizontal, 16)
          .padding(.bottom, 12)
        Spacer()
      }
    }
    .onAppear {
      GuestUploadModel.shared.isNotAccessRecord = false
    }
    .ignoresSafeArea()
    .onChange(of: isAccess) { newValue in
      if newValue {
        apiViewModel.myProfile = .init()
        apiViewModel.mainFeed = []
        tabbarModel.tabSelection = .main
        tabbarModel.tabSelectionNoAnimation = .main
        tabbarModel.tabbarOpacity = 1.0
      }
    }
    .onChange(of: bottomSheetPosition) { newValue in
      if newValue == .hidden {} else {
        tabbarModel.tabbarOpacity = 0.0
      }
    }
    .navigationDestination(isPresented: $showTermsOfService) {
      TermsOfServiceView()
    }
    .navigationDestination(isPresented: $showPrivacyPolicy) {
      PrivacyPolicyView()
    }
    .bottomSheet(
      bottomSheetPosition: $bottomSheetPosition,
      switchablePositions: [.hidden, .dynamic])
    {
      VStack(spacing: 0) {
        HStack {
          Spacer()
          Button {
            tabbarModel.tabbarOpacity = 1.0
            bottomSheetPosition = .hidden
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
      tabbarModel.tabbarOpacity = 1.0
    }
  }
}

extension GuestProfileView {
  @ViewBuilder
  func overlayedView() -> some View {
    VStack(spacing: 0) {
      Spacer()
        .frame(height: 48)
        .padding([.top, .horizontal], 16)
      Image("ProfileDefault")
        .resizable()
        .scaledToFit()
        .frame(height: 100)
        .padding(.bottom, 16)
      Text("로그인을 해주세요")
        .fontWeight(.semibold)
        .fontSystem(fontDesignSystem: .title2_Expanded)
        .foregroundColor(.LabelColor_Primary_Dark)
        .padding(4)
      Text("더 많은 스포츠 콘텐츠를 즐겨보세요")
        .fontSystem(fontDesignSystem: .body2)
        .foregroundColor(.LabelColor_Secondary_Dark)
        .padding(.bottom, 24)
      Button {
        bottomSheetPosition = .dynamic
      } label: {
        Text("가입하기")
          .fontSystem(fontDesignSystem: .subtitle2)
          .foregroundColor(.LabelColor_Primary_Dark)
          .hCenter()
          .frame(height: 48)
          .background {
            Capsule()
              .foregroundColor(.Blue_Default)
              .padding(.horizontal, 32)
          }
      }
      Spacer()
    }
  }
}
