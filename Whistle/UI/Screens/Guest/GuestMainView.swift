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
  @AppStorage("isAccess") var isAccess = false
  @StateObject var userAuth = UserAuth.shared
  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject var appleSignInViewModel = AppleSignInViewModel()
  @StateObject private var tabbarModel = TabbarModel.shared

  @State var currentIndex = 0
  @State var playerIndex = 0
  @State var currentVideoUserId = 0
  @State var currentVideoContentId = 0
  @State var players: [AVPlayer?] = []

  @State var isShowingBottomSheet = false
  @State var newId = UUID()

  @State var showTermsOfService = false
  @State var showPrivacyPolicy = false
  @State var bottomSheetPosition: BottomSheetPosition = .hidden

  @Binding var mainOpacity: Double

  let keychain = KeychainSwift()

  var body: some View {
    GeometryReader { proxy in
      TabView(selection: $currentIndex) {
        ForEach(Array(apiViewModel.guestFeed.enumerated()), id: \.element) { index, content in
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
                      musicTitle: content.musicTitle ?? "원본 오디오",
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
        if apiViewModel.guestFeed.isEmpty, players.isEmpty {
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
              Text(CommonWords().close)
                .fontSystem(fontDesignSystem: .subtitle2_KO)
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
          .background {
            Color.clear.overlay {
              Image("gestureGuide")
                .resizable()
                .scaleEffect(1.01)
                .scaledToFill()
            }
            .ignoresSafeArea()
          }
        }
      }
    }
    .ignoresSafeArea(.all, edges: .top)
    .navigationBarBackButtonHidden()
    .background(.black)
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
              .fontSystem(fontDesignSystem: .subtitle2_KO)
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
    .task {
      apiViewModel.requestGuestFeed {
        Task {
          if !apiViewModel.guestFeed.isEmpty {
            players.removeAll()
            for _ in 0 ..< apiViewModel.guestFeed.count {
              players.append(nil)
            }
            players[currentIndex] =
              AVPlayer(url: URL(string: apiViewModel.guestFeed[currentIndex].videoUrl ?? "")!)
            playerIndex = currentIndex
            guard let player = players[currentIndex] else {
              return
            }
            currentVideoUserId = apiViewModel.guestFeed[currentIndex].userId ?? 0
            currentVideoContentId = apiViewModel.guestFeed[currentIndex].contentId ?? 0
            await player.seek(to: .zero)
            player.play()
          }
        }
      }
    }
    .onChange(of: currentIndex) { newValue in
      guard let url = apiViewModel.guestFeed[newValue].videoUrl else {
        return
      }
      players[playerIndex]?.seek(to: .zero)
      players[playerIndex]?.pause()
      players[playerIndex] = nil
      players[newValue] = AVPlayer(url: URL(string: url)!)
      players[newValue]?.seek(to: .zero)
      players[newValue]?.play()
      playerIndex = newValue
      currentVideoUserId = apiViewModel.guestFeed[newValue].userId ?? 0
      currentVideoContentId = apiViewModel.guestFeed[newValue].contentId ?? 0
      apiViewModel.publisherSend()
      if (newValue + 1) % 3 == 0, newValue + 1 != 1 {
        bottomSheetPosition = .dynamic
      }
    }
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
      if apiViewModel.guestFeed.isEmpty, players.isEmpty {
        return
      }
      if players.isEmpty {
        return
      }
      guard players[currentIndex] != nil else {
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
              bottomSheetPosition = .dynamic
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
              bottomSheetPosition = .dynamic
            } label: {
              Text(CommonWords().follow)
                .fontSystem(fontDesignSystem: .caption_KO_Semibold)
                .foregroundColor(.Gray10)
                .frame(width: 58, height: 26)
                .background {
                  Capsule()
                    .stroke(Color.Gray30, lineWidth: 1)
                }
            }
          }
          if !caption.isEmpty {
            HStack(spacing: 0) {
              Text(caption)
                .fontSystem(fontDesignSystem: .body2_KO)
                .foregroundColor(.white)
            }
          }
          Label(musicTitle, systemImage: "music.note")
            .fontSystem(fontDesignSystem: .body2_KO)
            .foregroundColor(.white)
            .padding(.top, 4)
        }
        Spacer()
        VStack(spacing: 26) {
          Spacer()
          Button {
            bottomSheetPosition = .dynamic
          } label: {
            VStack(spacing: 2) {
              Image(systemName: "heart")
                .font(.system(size: 26))
                .frame(width: 36, height: 36)
              Text("\(whistleCount)")
                .fontSystem(fontDesignSystem: .caption_KO_Semibold)
            }
            .frame(height: UIScreen.getHeight(56))
          }
          Button {
            bottomSheetPosition = .dynamic
          } label: {
            VStack(spacing: 2) {
              Image(systemName: "square.and.arrow.up")
                .font(.system(size: 26))
                .frame(width: 36, height: 36)
              Text(CommonWords().share)
                .fontSystem(fontDesignSystem: .caption_KO_Semibold)
            }
            .frame(height: UIScreen.getHeight(56))
          }
          .fontSystem(fontDesignSystem: .caption_Regular)
          Button {
            bottomSheetPosition = .dynamic
          } label: {
            VStack(spacing: 2) {
              Image(systemName: "ellipsis")
                .font(.system(size: 26))
                .frame(width: 36, height: 36)
              Text(CommonWords().more)
                .fontSystem(fontDesignSystem: .caption_KO_Semibold)
            }
            .frame(height: UIScreen.getHeight(56))
          }
        }
        .foregroundColor(.Gray10)
      }
    }
    .padding(.bottom, UIScreen.getHeight(52))
    .padding(.horizontal, UIScreen.getWidth(16))
  }
}
