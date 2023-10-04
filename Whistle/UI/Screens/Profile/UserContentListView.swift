//
//  UserContentListView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/21/23.
//

import AVFoundation
import Kingfisher
import SwiftUI

// MARK: - UserContentListView

struct UserContentListView: View {

  @Environment(\.dismiss) var dismiss
  @EnvironmentObject var apiViewModel: APIViewModel
  @EnvironmentObject var tabbarModel: TabbarModel
  @State var currentIndex = 0
  @State var newId = UUID()
  @State var playerIndex = 0
  @State var showDialog = false
  @State var showPasteToast = false
  @State var showDeleteToast = false
  @State var players: [AVPlayer?] = []

  var body: some View {
    GeometryReader { proxy in
      TabView(selection: $currentIndex) {
        ForEach(Array(apiViewModel.userPostFeed.enumerated()), id: \.element) { index, content in
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
                  userInfo(
                    contentId: content.contentId ?? 0,
                    userName: content.userName ?? "",
                    profileImg: content.profileImg ?? "",
                    caption: content.caption ?? "",
                    musicTitle: content.musicTitle ?? "",
                    isWhistled:
                    Binding(get: {
                      content.isWhistled == 1 ? true : false
                    }, set: { newValue in
                      content.isWhistled = newValue ? 1 : 0
                    }),
                    whistleCount:
                    Binding(get: {
                      content.contentWhistleCount ?? 0
                    }, set: { newValue in
                      content.contentWhistleCount = newValue
                    }))
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
    }
    .ignoresSafeArea(.all, edges: .top)
    .navigationBarBackButtonHidden()
    .background(.black)
    .onAppear {
      log("apiViewModel.userPostFeed : \(apiViewModel.userPostFeed)")
      log("apiViewModel.userPostFeed.count : \(apiViewModel.userPostFeed.count)")
      log("currentIndex : \(currentIndex)")
      log("")
      for _ in 0..<apiViewModel.userPostFeed.count {
        players.append(nil)
      }
      log("players : \(players)")
      players[currentIndex] = AVPlayer(url: URL(string: apiViewModel.userPostFeed[currentIndex].videoUrl ?? "")!)
      log("players : \(players)")
      playerIndex = currentIndex
      players[currentIndex]?.seek(to: .zero)
      players[currentIndex]?.play()
      apiViewModel.postFeedPlayerChanged()
      log("onchange end")
    }
    .onChange(of: currentIndex) { newValue in
      log("실행")
      log(playerIndex)
      log(newValue)
      log(currentIndex)
      guard let url = apiViewModel.userPostFeed[newValue].videoUrl else {
        return
      }
      players[newValue] = AVPlayer(url: URL(string: url)!)
      players[playerIndex]?.seek(to: .zero)
      players[playerIndex]?.pause()
      players[playerIndex] = nil
      players[newValue]?.seek(to: .zero)
      players[newValue]?.play()
      playerIndex = newValue
      apiViewModel.postFeedPlayerChanged()
    }
    .overlay {
      if showPasteToast {
        ToastMessage(text: "클립보드에 복사되었어요", paddingBottom: 78, showToast: $showPasteToast)
      }
      if showDeleteToast {
        CancelableToastMessage(text: "삭제되었습니다", paddingBottom: 78, action: {
          Task {
            guard let contentId = apiViewModel.userPostFeed[currentIndex].contentId else { return }
            log("contentId: \(contentId)")
            log("currentIndex: \(currentIndex)")
            log("playerIndex: \(playerIndex)")
            apiViewModel.userPostFeed.remove(at: currentIndex)
            players[currentIndex]?.pause()
            players.remove(at: currentIndex)
            if !players.isEmpty {
              players[currentIndex] = AVPlayer(url: URL(string: apiViewModel.userPostFeed[currentIndex].videoUrl ?? "")!)
              await players[currentIndex]?.seek(to: .zero)
              players[currentIndex]?.play()
            }
            apiViewModel.postFeedPlayerChanged()
            log("contentId: \(contentId)")
            log("currentIndex: \(currentIndex)")
            log("playerIndex: \(currentIndex)")
//            await apiViewModel.deleteContent(contentId: contentId)
          }
        }, showToast: $showDeleteToast)
      }
    }
    .confirmationDialog("", isPresented: $showDialog) {
      Button("삭제하기", role: .destructive) {
        showDeleteToast = true
      }
      Button("닫기", role: .cancel) {
        log("Cancel")
      }
    }
    .onDisappear {
      players[currentIndex]?.pause()
    }
  }
}

extension UserContentListView {

  @ViewBuilder
  func userInfo(
    contentId: Int?,
    userName: String,
    profileImg: String,
    caption: String,
    musicTitle: String,
    isWhistled: Binding<Bool>,
    whistleCount: Binding<Int>)
    -> some View
  {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        Button {
          players[currentIndex]?.pause()
          players.removeAll()
          dismiss()
        } label: {
          Color.clear
            .frame(width: 24, height: 24)
            .overlay {
              Image(systemName: "chevron.backward")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 20)
                .foregroundColor(.white)
            }
        }
        Spacer()
      }
      .frame(height: 52)
      .padding(.top, 54)

      Spacer()
      HStack(spacing: 0) {
        VStack(alignment: .leading, spacing: 12) {
          Spacer()
          HStack(spacing: 0) {
            Group {
              profileImageView(url: profileImg, size: 36)
                .padding(.trailing, 12)
              Text(userName)
                .foregroundColor(.white)
                .fontSystem(fontDesignSystem: .subtitle1)
                .padding(.trailing, 16)
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
            Task {
              if isWhistled.wrappedValue {
                guard let contentId else { return }
                await apiViewModel.actionWhistleCancel(contentId: contentId)
                whistleCount.wrappedValue -= 1
              } else {
                guard let contentId else { return }
                await apiViewModel.actionWhistle(contentId: contentId)
                whistleCount.wrappedValue += 1
              }
              isWhistled.wrappedValue.toggle()
              apiViewModel.postFeedPlayerChanged()
            }
          } label: {
            VStack(spacing: 0) {
              Image(systemName: isWhistled.wrappedValue ? "heart.fill" : "heart")
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 26)
                .foregroundColor(.Gray10)
                .padding(.bottom, 2)
              Text("\(whistleCount.wrappedValue)")
                .foregroundColor(.Gray10)
                .fontSystem(fontDesignSystem: .caption_Regular)
                .padding(.bottom, 24)
            }
          }
          Button {
            showPasteToast = true
            UIPasteboard.general.setValue(
              "복사할 링크입니다.",
              forPasteboardType: UTType.plainText.identifier)
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
            showDialog = true
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
