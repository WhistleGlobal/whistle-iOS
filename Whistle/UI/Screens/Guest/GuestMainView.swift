//
//  GuestMainView.swift
//  Whistle
//
//  Created by ChoiYujin on 10/4/23.
//

import _AuthenticationServices_SwiftUI
import _AVKit_SwiftUI
import AVFoundation
import BottomSheet
import GoogleSignIn
import KeychainSwift
import Kingfisher
import SwiftUI

// MARK: - GuestMainView

struct GuestMainView: View {
  @AppStorage("showGuide") var showGuide = true
  @StateObject var apiViewModel = APIViewModel.shared
  @EnvironmentObject var userAuth: UserAuth
  @State var currentIndex = 0
  @State var playerIndex = 0
  @State var currentVideoUserId = 0
  @State var currentVideoContentId = 0
  @State var isShowingBottomSheet = false
  @State var players: [AVPlayer?] = []
  @State var newId = UUID()
  @State var showTermsOfService = false
  @State var showPrivacyPolicy = false
  @State var bottomSheetPosition: BottomSheetPosition = .hidden
  @StateObject var appleSignInViewModel = AppleSignInViewModel()
  @StateObject private var tabbarModel = TabbarModel.shared
  @Binding var mainOpacity: Double
  @AppStorage("isAccess") var isAccess = false
  let keychain = KeychainSwift()
  var domainURL: String {
    AppKeys.domainURL as! String
  }

  var body: some View {
    GeometryReader { proxy in
      TabView(selection: $currentIndex) {
        ForEach(Array(apiViewModel.noSignInContentList.enumerated()), id: \.element) { index, content in
          if !players.isEmpty {
            if let player = players[index] {
              ContentPlayer(player: player)
                .frame(width: proxy.size.width)
                .onTapGesture {
                  if player.rate == 0.0 {
                    player.play()
                  } else {
                    player.pause()
                  }
                }
                .overlay {
                  LinearGradient(
                    colors: [.clear, .black.opacity(0.24)],
                    startPoint: .center,
                    endPoint: .bottom)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .allowsHitTesting(false)
                  if tabbarModel.tabWidth != 56 {
                    userInfo(
                      contentId: content.contentId ?? 0,
                      userName: content.userName ?? "",
                      profileImg: content.profileImg ?? "",
                      caption: content.caption ?? "",
                      musicTitle: content.musicTitle ?? "",
                      whistleCount: content.whistleCount ?? 0)
                  }
                }
                .padding()
                .rotationEffect(Angle(degrees: -90))
                .ignoresSafeArea(.all, edges: .top)
                .tag(index)
            } else {
              KFImage.url(URL(string: content.thumbnailUrl ?? ""))
                .placeholder {
                  Color.black
                }
                .resizable()
                .scaledToFill()
                .tag(index)
                .frame(width: proxy.size.width)
                .padding()
                .rotationEffect(Angle(degrees: -90))
                .ignoresSafeArea(.all, edges: .top)
            }
          }
        }
        .onReceive(apiViewModel.publisher) { id in
          newId = id
        }
        .id(newId)
      }
      .rotationEffect(Angle(degrees: 90))
      .frame(width: proxy.size.height)
      .tabViewStyle(.page(indexDisplayMode: .never))
      .frame(maxWidth: proxy.size.width)
      .onChange(of: mainOpacity) { newValue in
        if apiViewModel.noSignInContentList.isEmpty, players.isEmpty {
          return
        }
        if players.count <= currentIndex {
          return
        }
        guard let player = players[currentIndex] else {
          return
        }
        if newValue == 1 {
          player.play()
        } else {
          player.pause()
        }
      }
      .overlay {
        if showGuide {
          VStack {
            Spacer()
            Button {
              showGuide = false
            } label: {
              Text("닫기")
                .fontSystem(fontDesignSystem: .subtitle2_KO)
                .foregroundColor(Color.LabelColor_Primary_Dark)
                .background {
                  glassMorphicView(width: UIScreen.width - 32, height: 56, cornerRadius: 12)
                    .overlay {
                      RoundedRectangle(cornerRadius: 12)
                        .stroke(lineWidth: 1)
                        .foregroundStyle(
                          LinearGradient.Border_Glass)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .frame(width: UIScreen.width - 32, height: 56)
            .padding(.bottom, 32)
          }
          .ignoresSafeArea()
          .ignoresSafeArea(.all, edges: .top)
          .background {
            Color.clear.overlay {
              Image("gestureGuide")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .ignoresSafeArea(.all, edges: .top)
            }
            .ignoresSafeArea()
            .ignoresSafeArea(.all, edges: .top)
          }
        }
      }
    }
    .ignoresSafeArea(.all, edges: .top)
    .navigationBarBackButtonHidden()
    .background(.black)
    .bottomSheet(
      bottomSheetPosition: $bottomSheetPosition,
      switchablePositions: [.hidden, .absolute(UIScreen.height - 68)])
    {
      VStack(spacing: 0) {
        HStack {
          Button {
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
    .task {
      log("Task executed")
      log("apiViewModel.noSignInContentList : \(apiViewModel.noSignInContentList)")

      log("isEmpty")
      apiViewModel.requestNoSignInContent {
        log("request executed")
        Task {
          if !apiViewModel.noSignInContentList.isEmpty {
            players.removeAll()
            for _ in 0 ..< apiViewModel.noSignInContentList.count {
              players.append(nil)
            }
            players[currentIndex] =
              AVPlayer(url: URL(string: apiViewModel.noSignInContentList[currentIndex].videoUrl ?? "")!)
            playerIndex = currentIndex
            guard let player = players[currentIndex] else {
              return
            }
            currentVideoUserId = apiViewModel.noSignInContentList[currentIndex].userId ?? 0
            currentVideoContentId = apiViewModel.noSignInContentList[currentIndex].contentId ?? 0
            await player.seek(to: .zero)
            player.play()
          }
        }
      }
    }
    .onChange(of: currentIndex) { newValue in
      guard let url = apiViewModel.noSignInContentList[newValue].videoUrl else {
        return
      }
      players[playerIndex]?.seek(to: .zero)
      players[playerIndex]?.pause()
      players[playerIndex] = nil
      players[newValue] = AVPlayer(url: URL(string: url)!)
      players[newValue]?.seek(to: .zero)
      players[newValue]?.play()
      playerIndex = newValue
      currentVideoUserId = apiViewModel.noSignInContentList[newValue].userId ?? 0
      currentVideoContentId = apiViewModel.noSignInContentList[newValue].contentId ?? 0
      apiViewModel.postFeedPlayerChanged()
      if (newValue + 1) % 3 == 0, newValue + 1 != 1 {
        bottomSheetPosition = .absolute(UIScreen.height - 68)
      }
    }
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
      if newValue == .hidden {
        tabbarModel.tabbarOpacity = 1.0
      } else {
        tabbarModel.tabbarOpacity = 0.0
      }
    }
    .onChange(of: tabbarModel.tabbarOpacity) { newValue in
      if players.isEmpty {
        return
      }
      if newValue == 1.0 {
        players[currentIndex]?.play()
      } else {
        players[currentIndex]?.pause()
      }
    }
    .navigationDestination(isPresented: $showTermsOfService) {
      TermsOfServiceView()
    }
    .navigationDestination(isPresented: $showPrivacyPolicy) {
      PrivacyPolicyView()
    }
    .onChange(of: mainOpacity) { newValue in
      if apiViewModel.noSignInContentList.isEmpty, players.isEmpty {
        return
      }
      if players.isEmpty {
        return
      }
      guard let player = players[currentIndex] else {
        return
      }
      if newValue == 1 {
        players[currentIndex]?.play()
      } else {
        players[currentIndex]?.pause()
      }
    }
  }
}

extension GuestMainView {
  @ViewBuilder
  func userInfo(
    contentId _: Int,
    userName: String,
    profileImg: String,
    caption: String,
    musicTitle: String,
    whistleCount: Int)
    -> some View
  {
    VStack(spacing: 0) {
      Spacer()
      HStack(spacing: 0) {
        VStack(alignment: .leading, spacing: 12) {
          Spacer()
          HStack(spacing: 0) {
            Button {
              bottomSheetPosition = .absolute(UIScreen.height - 68)
            } label: {
              Group {
                profileImageView(url: profileImg, size: 36)
                  .padding(.trailing, 12)
                Text(userName)
                  .foregroundColor(.white)
                  .fontSystem(fontDesignSystem: .subtitle1)
                  .padding(.trailing, 16)
              }
            }
            Button {
              bottomSheetPosition = .absolute(UIScreen.height - 68)
            } label: {
              Text("follow")
                .fontSystem(fontDesignSystem: .caption_SemiBold)
                .foregroundColor(.Gray10)
                .background {
                  Capsule()
                    .stroke(Color.Border_Default, lineWidth: 1)
                    .frame(width: 60, height: 26)
                }
                .frame(width: 60, height: 26)
            }
          }
          HStack(spacing: 0) {
            Text(caption)
              .fontSystem(fontDesignSystem: .body2_KO)
              .foregroundColor(.white)
          }
          Label(musicTitle, systemImage: "music.note")
            .fontSystem(fontDesignSystem: .body2_KO)
            .foregroundColor(.white)
        }
        Spacer()
        VStack(spacing: 0) {
          Spacer()
          Button {
            bottomSheetPosition = .absolute(UIScreen.height - 68)
          } label: {
            VStack(spacing: 0) {
              Image(systemName: "heart")
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 26)
                .foregroundColor(.Gray10)
                .padding(.bottom, 2)
              Text("\(whistleCount)")
                .foregroundColor(.Gray10)
                .fontSystem(fontDesignSystem: .caption_Regular)
                .padding(.bottom, 24)
            }
          }
          Button {
            bottomSheetPosition = .absolute(UIScreen.height - 68)
          } label: {
            Image(systemName: "square.and.arrow.up")
              .resizable()
              .scaledToFit()
              .frame(width: 25, height: 32)
              .foregroundColor(.Gray10)
              .padding(.bottom, 24)
          }
          .fontSystem(fontDesignSystem: .caption_Regular)
          Button {
            bottomSheetPosition = .absolute(UIScreen.height - 68)
          } label: {
            Image(systemName: "ellipsis")
              .resizable()
              .scaledToFit()
              .frame(width: 30, height: 25)
              .foregroundColor(.Gray10)
          }
        }
      }
    }
    .padding(.bottom, 64)
    .padding(.horizontal, 20)
  }
}

extension GuestMainView {
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
