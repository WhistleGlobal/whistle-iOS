//
//  BookmarkedFeedView.swift
//  Whistle
//
//  Created by ChoiYujin on 10/6/23.
//

import AVFoundation
import Kingfisher
import SwiftUI

// MARK: - BookmarkedFeedView

struct BookmarkedFeedView: View {
  @Environment(\.dismiss) var dismiss
  @StateObject var apiViewModel = APIViewModel.shared
  @State var currentIndex = 0
  @State var newID = UUID()
  @State var playerIndex = 0
  @State var showDialog = false
  @State var showPasteToast = false
  @State var showDeleteToast = false
  @State var showPlayButton = false
  @State var timer: Timer? = nil
  @State var players: [AVPlayer?] = []

  var body: some View {
    GeometryReader { proxy in
      if apiViewModel.bookmark.isEmpty {
        Color.black.ignoresSafeArea().overlay {
          VStack(spacing: 16) {
            HStack(spacing: 0) {
              Button {
                if !players.isEmpty {
                  players[currentIndex]?.pause()
                  players.removeAll()
                }
                dismiss()
              } label: {
                Image(systemName: "chevron.backward")
                  .font(.system(size: 20))
                  .foregroundColor(.white)
                  .padding(.vertical, 16)
                  .padding(.trailing, 16)
              }
              Spacer()
            }
            .padding(.top, 54)
            .padding(.horizontal, 16)
            Spacer()
            Image(systemName: "photo")
              .resizable()
              .scaledToFit()
              .frame(width: 60)
              .foregroundColor(.LabelColor_Primary_Dark)
            Text("콘텐츠가 없습니다")
              .fontSystem(fontDesignSystem: .body1_KO)
              .foregroundColor(.LabelColor_Primary_Dark)
            Spacer()
          }
        }
      } else {
        TabView(selection: $currentIndex) {
          ForEach(Array(apiViewModel.bookmark.enumerated()), id: \.element) { index, content in
            if !players.isEmpty {
              if let player = players[index] {
                ContentPlayer(player: player)
                  .frame(width: proxy.size.width)
                  .onChange(of: TabbarModel.shared.tabSelectionNoAnimation) { newValue in
                    if newValue != .profile {
                      player.pause()
                    }
                  }
                  .onTapGesture(count: 2) {
                    whistleToggle()
                  }
                  .onTapGesture {
                    if player.rate == 0.0 {
                      player.play()
                      showPlayButton = true
                      DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        withAnimation {
                          showPlayButton = false
                        }
                      }
                    } else {
                      player.pause()
                      showPlayButton = true
                      DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        withAnimation {
                          showPlayButton = false
                        }
                      }
                    }
                  }
                  .onLongPressGesture {
                    HapticManager.instance.impact(style: .medium)
                    showDialog = true
                  }
                  .overlay {
                    LinearGradient(
                      colors: [.clear, .black.opacity(0.24)],
                      startPoint: .center,
                      endPoint: .bottom)
                      .frame(maxWidth: .infinity, maxHeight: .infinity)
                      .allowsHitTesting(false)
                    userInfo(
                      contentId: content.contentId,
                      userName: content.userName,
                      caption: content.caption ?? "",
                      musicTitle: content.musicTitle ?? "원본 오디오",
                      isWhistled:
                      Binding(get: {
                        content.isWhistled == 1 ? true : false
                      }, set: { newValue in
                        content.isWhistled = newValue ? 1 : 0
                      }),
                      whistleCount:
                      Binding(get: {
                        content.whistleCount
                      }, set: { newValue in
                        content.whistleCount = newValue
                      }))
                    playButton(toPlay: player.rate == 0)
                      .opacity(showPlayButton ? 1 : 0)
                      .allowsHitTesting(false)
                  }
                  .padding()
                  .rotationEffect(Angle(degrees: -90))
                  .ignoresSafeArea(.all, edges: .top)
                  .tag(index)
              } else {
                KFImage.url(URL(string: content.thumbnailUrl))
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
            newID = id
          }
          .id(newID)
        }
        .rotationEffect(Angle(degrees: 90))
        .frame(width: proxy.size.height)
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(maxWidth: proxy.size.width)
      }
    }
    .ignoresSafeArea(.all, edges: .top)
    .navigationBarBackButtonHidden()
    .background(.black)
    .onAppear {
      for _ in 0 ..< apiViewModel.bookmark.count {
        players.append(nil)
      }
      players[currentIndex] = AVPlayer(url: URL(string: apiViewModel.bookmark[currentIndex].videoUrl)!)
      playerIndex = currentIndex
      guard let player = players[currentIndex] else {
        return
      }
      player.seek(to: .zero)
      player.play()
    }
    .onChange(of: currentIndex) { newValue in
      if apiViewModel.bookmark.isEmpty {
        return
      }
      let url = apiViewModel.bookmark[newValue].videoUrl
      players[newValue] = AVPlayer(url: URL(string: url)!)
      if playerIndex < players.count {
        players[playerIndex]?.seek(to: .zero)
        players[playerIndex]?.pause()
        players[playerIndex] = nil
      }
      players[newValue]?.seek(to: .zero)
      players[newValue]?.play()
      playerIndex = newValue
      apiViewModel.postFeedPlayerChanged()
    }
    .overlay {
      if showPasteToast {
        ToastMessage(text: "클립보드에 복사되었어요", toastPadding: 78, showToast: $showPasteToast)
      }
      if showDeleteToast {
        CancelableToastMessage(text: "저장 해제되었습니다.", paddingBottom: 78, action: {
          Task {
            if apiViewModel.bookmark.count - 1 != currentIndex { // 삭제하려는 컨텐츠가 배열 마지막이 아님
              let contentId = apiViewModel.bookmark[currentIndex].contentId
              apiViewModel.bookmark.remove(at: currentIndex)
              players[currentIndex]?.pause()
              players.remove(at: currentIndex)
              if !players.isEmpty {
                players[currentIndex] = AVPlayer(url: URL(string: apiViewModel.bookmark[currentIndex].videoUrl)!)
                await players[currentIndex]?.seek(to: .zero)
                players[currentIndex]?.play()
              }
              apiViewModel.postFeedPlayerChanged()
              _ = await apiViewModel.actionBookmarkCancel(contentID: contentId)
            } else {
              let contentId = apiViewModel.bookmark[currentIndex].contentId
              apiViewModel.bookmark.removeLast()
              players.last??.pause()
              players.removeLast()
              currentIndex -= 1
              apiViewModel.postFeedPlayerChanged()
              _ = await apiViewModel.actionBookmarkCancel(contentID: contentId)
            }
          }
        }, showToast: $showDeleteToast)
      }
    }
    .confirmationDialog("", isPresented: $showDialog) {
      Button("저장 해제", role: .destructive) {
        showDeleteToast = true
      }
      Button("닫기", role: .cancel) { }
    }
  }
}

extension BookmarkedFeedView {
  @ViewBuilder
  func userInfo(
    contentId: Int,
    userName: String,
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
          Image(systemName: "chevron.backward")
            .font(.system(size: 20))
            .foregroundColor(.white)
            .padding(.vertical, 16)
            .padding(.trailing, 16)
        }
        Spacer()
      }
      .padding(.top, 38)
      Spacer()
      HStack(spacing: 0) {
        VStack(alignment: .leading, spacing: 12) {
          Spacer()
          HStack(spacing: 0) {
            Group {
              profileImageView(url: apiViewModel.bookmark[currentIndex].profileImg, size: 36)
                .padding(.trailing, UIScreen.getWidth(8))
              Text(userName)
                .foregroundColor(.white)
                .fontSystem(fontDesignSystem: .subtitle1)
                .padding(.trailing, 16)
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
        .padding(.bottom, 4)
        .padding(.leading, 4)
        Spacer()
        VStack(spacing: 28) {
          Spacer()
          Button {
            Task {
              if isWhistled.wrappedValue {
                await apiViewModel.actionWhistleCancel(contentID: contentId)
                whistleCount.wrappedValue -= 1
              } else {
                await apiViewModel.actionWhistle(contentID: contentId)
                whistleCount.wrappedValue += 1
              }
              isWhistled.wrappedValue.toggle()
              apiViewModel.postFeedPlayerChanged()
            }
          } label: {
            VStack(spacing: 0) {
              Image(systemName: isWhistled.wrappedValue ? "heart.fill" : "heart")
                .font(.system(size: 30))
                .contentShape(Rectangle())
                .foregroundColor(.Gray10)
                .frame(width: 36, height: 36)
              Text("\(whistleCount.wrappedValue)")
                .foregroundColor(.Gray10)
                .fontSystem(fontDesignSystem: .caption_Regular)
            }
            .padding(.bottom, -4)
          }
          Button {
            showPasteToast = true
            UIPasteboard.general.setValue(
              "https://readywhistle.com/content_uni?contentId=\(apiViewModel.bookmark[currentIndex].contentId)",
              forPasteboardType: UTType.plainText.identifier)
          } label: {
            Image(systemName: "square.and.arrow.up")
              .font(.system(size: 30))
              .contentShape(Rectangle())
              .foregroundColor(.Gray10)
              .frame(width: 36, height: 36)
          }
          Button {
            showDialog = true
          } label: {
            Image(systemName: "ellipsis")
              .font(.system(size: 30))
              .contentShape(Rectangle())
              .foregroundColor(.Gray10)
              .frame(width: 36, height: 36)
          }
        }
      }
    }
    .ignoresSafeArea(.all, edges: .bottom)
    .padding(.bottom, UIScreen.getHeight(48))
    .padding(.trailing, UIScreen.getWidth(12))
    .padding(.leading, UIScreen.getWidth(16))
  }
}

// MARK: - Timer

extension BookmarkedFeedView {
  func whistleToggle() {
    HapticManager.instance.impact(style: .medium)
    timer?.invalidate()
    if apiViewModel.bookmark[currentIndex].isWhistled == 1 {
      let contentId = apiViewModel.bookmark[currentIndex].contentId
      timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
        Task {
          await apiViewModel.actionWhistleCancel(contentID: contentId)
        }
      }
      apiViewModel.bookmark[currentIndex].whistleCount -= 1
    } else {
      let contentId = apiViewModel.bookmark[currentIndex].contentId
      timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
        Task {
          await apiViewModel.actionWhistle(contentID: contentId)
        }
      }
      apiViewModel.bookmark[currentIndex].whistleCount += 1
    }
    apiViewModel.bookmark[currentIndex].isWhistled = apiViewModel.bookmark[currentIndex].isWhistled == 1 ? 0 : 1
    apiViewModel.postFeedPlayerChanged()
  }
}
