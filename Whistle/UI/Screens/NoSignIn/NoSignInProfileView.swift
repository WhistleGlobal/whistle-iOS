//
//  NoSignInProfileView.swift
//  Whistle
//
//  Created by ChoiYujin on 10/4/23.
//

import _AuthenticationServices_SwiftUI
import BottomSheet
import GoogleSignIn
import KeychainSwift
import SwiftUI

// MARK: - NoSignInProfileView

struct NoSignInProfileView: View {
  @EnvironmentObject var userAuth: UserAuth
  @EnvironmentObject var apiViewModel: APIViewModel
  @StateObject var appleSignInViewModel = AppleSignInViewModel()
  @StateObject private var tabbarModel = TabbarModel.shared
  @State var bottomSheetPosition: BottomSheetPosition = .hidden
  @State var showTermsOfService = false
  @State var showPrivacyPolicy = false
  @AppStorage("isAccess") var isAccess = false
  let keychain = KeychainSwift()
  var domainURL: String {
    AppKeys.domainURL as! String
  }

  var body: some View {
    ZStack {
      Color.clear.overlay {
        Image("DefaultBG")
          .resizable()
          .scaledToFill()
          .blur(radius: 50)
          .scaleEffect(1.4)
      }
      VStack(spacing: 0) {
        Spacer().frame(height: 64)
        glassProfile(
          width: UIScreen.width - 32,
          height: 340,
          cornerRadius: 32,
          overlayed: overlayedView())
          .padding(.bottom, 12)
        Spacer()
      }
    }
    .ignoresSafeArea()
    .onChange(of: isAccess) { newValue in
      if newValue {
        apiViewModel.myProfile = .init()
        apiViewModel.contentList = []
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
      switchablePositions: [.hidden, .absolute(UIScreen.height - 68)])
    {
      VStack(spacing: 0) {
        HStack {
          Button {
            tabbarModel.tabbarOpacity = 1.0
            bottomSheetPosition = .hidden
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
  }
}

extension NoSignInProfileView {
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
        .fontSystem(fontDesignSystem: .body2_KO)
        .foregroundColor(.LabelColor_Secondary_Dark)
        .padding(.bottom, 24)
      Button {
        bottomSheetPosition = .absolute(UIScreen.height - 68)
      } label: {
        Text("가입하기")
          .fontSystem(fontDesignSystem: .subtitle2_KO)
          .foregroundColor(.LabelColor_Primary_Dark)
          .frame(maxWidth: .infinity)
          .background {
            Capsule()
              .foregroundColor(.Blue_Default)
              .frame(width: .infinity, height: 48)
              .padding(.horizontal, 32)
          }
      }
      Spacer()
    }
  }
}

extension NoSignInProfileView {
  // 구글 로그인 버튼 클릭 처리
  func handleSignInButton() {
    // rootViewController 찾기
    guard
      let rootViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?
        .rootViewController
    else {
      return
    }
    GIDSignIn.sharedInstance.signIn(
      withPresenting: rootViewController)
    { signInResult, error in

      guard let result = signInResult else {
        return
      }
      result.user.refreshTokensIfNeeded { user, error in
        guard error == nil else { return }
        guard let user else { return }

        let idToken = user.idToken
        keychain.set("", forKey: "refresh_token")
        if let idTokenString = idToken?.tokenString {
          print("저장될 ID 토큰: \(idTokenString)")
          keychain.set(idTokenString, forKey: "id_token")
        }
        userAuth.provider = .google
        tokenSignIn(idToken: keychain.get("id_token") ?? "")
      }
    }

    func tokenSignIn(idToken: String) {
      guard let authData = try? JSONEncoder().encode(["idToken": idToken]) else {
        print("JSON 인코딩 실패")
        return
      }

      guard let url = URL(string: "\(domainURL)/auth/google") else {
        print("URL is nil")
        return
      }
      log("\(idToken)")
      var request = URLRequest(url: url)
      request.httpMethod = "POST"
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")

      let task = URLSession.shared.uploadTask(with: request, from: authData) { _, _, error in
        if let error {
          print("서버 통신 에러: \(error)")
        }
        DispatchQueue.main.async {
          userAuth.loadData { }
        }
      }
      task.resume()
    }
  }
}

#Preview {
  NavigationStack {
    NoSignInProfileView()
      .environmentObject(UserAuth())
  }
}
