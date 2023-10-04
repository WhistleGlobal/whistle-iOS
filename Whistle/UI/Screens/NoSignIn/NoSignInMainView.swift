//
//  NoSignInMainView.swift
//  Whistle
//
//  Created by ChoiYujin on 10/4/23.
//

import _AVKit_SwiftUI
import AVFoundation
import Kingfisher
import SwiftUI

// MARK: - NoSignInMainView

struct NoSignInMainView: View {

  @EnvironmentObject var apiViewModel: APIViewModel
  @EnvironmentObject var tabbarModel: TabbarModel
  @State var currentIndex = 0
  @State var playerIndex = 0
  @State var currentVideoUserId = 0
  @State var currentVideoContentId = 0
  @State var isShowingBottomSheet = false
  @State var players: [AVPlayer?] = []
  @State var newId = UUID()
  @Binding var mainOpacity: Double

  var body: some View {
    GeometryReader { proxy in
      TabView(selection: $currentIndex) {
        ForEach(Array(apiViewModel.noSignInContentList.enumerated()), id: \.element) { index, content in
          if !players.isEmpty {
            if let player = players[index] {
              Player(player: player)
                .frame(width: proxy.size.width)
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
    .ignoresSafeArea(.all, edges: .top)
    .navigationBarBackButtonHidden()
    .background(.black)
    .task {
      if apiViewModel.noSignInContentList.isEmpty {
        apiViewModel.requestNoSignInContent {
          Task {
            if !apiViewModel.noSignInContentList.isEmpty {
              players.removeAll()
              for _ in 0..<apiViewModel.noSignInContentList.count {
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
    }
  }
}

extension NoSignInMainView {
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
              // FIXME: - 고치기
              log("")
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
              // FIXME: - 고치기
              log("")
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
            // FIXME: - 고치기
            log("")
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
            // FIXME: - 고치기
            log("")
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
            // FIXME: - 고치기
            log("")
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
    .padding(.bottom, 112)
    .padding(.horizontal, 20)
  }
}
