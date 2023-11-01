//
//  SignInView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/1/23.
//

import _AuthenticationServices_SwiftUI
import _AVKit_SwiftUI
import AVFoundation
import GoogleSignIn
import GoogleSignInSwift
import KeychainSwift
import Security
import SwiftUI

// MARK: - SignInView

struct SignInView: View {
  @Environment(\.scenePhase) var scenePhase
  @EnvironmentObject var universalRoutingModel: UniversalRoutingModel
  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject var appleSignInViewModel = AppleSignInViewModel()
  @StateObject var userAuth = UserAuth.shared
  @State var showTermsOfService = false
  @State var showPrivacyPolicy = false
  @State var showUpdate = false
  @State var loginOpacity = 0.0

  private var customViewModel = GoogleSignInButtonViewModel(scheme: .light, style: .standard, state: .normal)

  var body: some View {
    ZStack {
      if scenePhase == .active || scenePhase == .inactive {
        SignInPlayer()
          .ignoresSafeArea()
          .allowsTightening(false)
      }
      VStack(spacing: 0) {
        HStack(spacing: 0) {
          Spacer()
          NavigationLink {
            RootTabView()
              .environmentObject(universalRoutingModel)
          } label: {
            Text("건너뛰기")
              .fontSystem(fontDesignSystem: .subtitle2_KO)
              .foregroundColor(.LabelColor_Secondary_Dark)
          }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
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
        .padding(.bottom, 16)
      }
      .opacity(loginOpacity)
    }
    .alert(isPresented: $showUpdate) {
      Alert(
        title: Text("업데이트 알림"),
        message: Text("Whistle의 새로운 버전이 있습니다. 최신 버전으로 업데이트 해주세요."),
        dismissButton: .default(Text("업데이트"), action: {
          guard let url = URL(string: "itms-apps://itunes.apple.com/app/6463850354") else { return }
          if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
          }
        }))
    }
    .onAppear {
      apiViewModel.reset()
      apiViewModel.publisherSend()
      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        if apiViewModel.versionCheck.forceUpdate {
          showUpdate = true
        } else {
          withAnimation {
            loginOpacity = 1.0
          }
        }
      }
    }
    .navigationDestination(isPresented: $showTermsOfService) {
      TermsOfServiceView()
    }
    .navigationDestination(isPresented: $showPrivacyPolicy) {
      PrivacyPolicyView()
    }
  }
}
