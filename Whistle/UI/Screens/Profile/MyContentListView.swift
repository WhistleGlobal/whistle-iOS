//
//  MyContentListView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/20/23.
//

import AVFoundation
import Kingfisher
import SwiftUI

// MARK: - MyContentListView

struct MyContentListView: View {

  @Environment(\.dismiss) var dismiss
  @State var currentIndex = 0
  @State var newId = UUID()
  @State var playerIndex = 0
  @State var showDialog = false
  @State var showPasteToast = false
  @State var showDeleteToast = false
  @State var timer: Timer? = nil
  @EnvironmentObject var apiViewModel: APIViewModel
  @EnvironmentObject var tabbarModel: TabbarModel
  @State var players: [AVPlayer?] = []

  var body: some View {
    GeometryReader { proxy in
      if apiViewModel.myPostFeed.isEmpty {
        // FIXME: - 디자인수정
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
          ForEach(Array(apiViewModel.myPostFeed.enumerated()), id: \.element) { index, content in
            if !players.isEmpty {
              if let player = players[index] {
                Player(player: player)
                  .frame(width: proxy.size.width)
                  .onTapGesture(count: 2) {
                    whistleToggle()
                  }
                  .onTapGesture {
                    if player.rate == 0.0 {
                      player.play()
                    } else {
                      player.pause()
                    }
                  }
                  .onLongPressGesture {
                    HapticManager.instance.impact(style: .medium)
                    showDialog = true
                  }
                  .overlay {
                    // TODO: - contentId 백엔드 수정 필요, contentId & whistleCount
                    LinearGradient(
                      colors: [.clear, .black.opacity(0.24)],
                      startPoint: .center,
                      endPoint: .bottom)
                      .frame(maxWidth: .infinity, maxHeight: .infinity)
                      .allowsHitTesting(false)
                    userInfo(
                      contentId: content.contentId ?? 0,
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
                Color.black
                  .tag(index)
                  .frame(width: proxy.size.width)
                  .padding()
                  .rotationEffect(Angle(degrees: -90))
                  .ignoresSafeArea(.all, edges: .top)
//                KFImage.url(URL(string: content.thumbnailUrl ?? ""))
//                  .placeholder {
//                    Color.black
//                  }
//                  .resizable()
//                  .scaledToFill()
//                  .tag(index)
//                  .frame(width: proxy.size.width)
//                  .padding()
//                  .rotationEffect(Angle(degrees: -90))
//                  .ignoresSafeArea(.all, edges: .top)
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
    }
    .ignoresSafeArea(.all, edges: .top)
    .navigationBarBackButtonHidden()
    .background(.black)
    .onAppear {
      for _ in 0..<apiViewModel.myPostFeed.count {
        players.append(nil)
      }
      players[currentIndex] = AVPlayer(url: URL(string: apiViewModel.myPostFeed[currentIndex].videoUrl ?? "")!)
      playerIndex = currentIndex
      guard let player = players[currentIndex] else {
        return
      }
      player.seek(to: .zero)
      player.play()
    }
    .onChange(of: currentIndex) { newValue in
      if apiViewModel.myPostFeed.isEmpty {
        return
      }
      log(playerIndex)
      log(newValue)
      log(currentIndex)
      guard let url = apiViewModel.myPostFeed[newValue].videoUrl else {
        return
      }
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
        ToastMessage(text: "클립보드에 복사되었어요", toastPadding: 70, isTopAlignment: true, showToast: $showPasteToast)
      }
      if showDeleteToast {
        CancelableToastMessage(text: "삭제되었습니다", paddingBottom: 78, action: {
          Task {
            if apiViewModel.myPostFeed.count - 1 != currentIndex { // 삭제하려는 컨텐츠가 배열 마지막이 아님
              guard let contentId = apiViewModel.myPostFeed[currentIndex].contentId else { return }
              log("contentId: \(contentId)")
              log("currentIndex: \(currentIndex)")
              log("playerIndex: \(playerIndex)")
              apiViewModel.myPostFeed.remove(at: currentIndex)
              players[currentIndex]?.pause()
              players.remove(at: currentIndex)
              if !players.isEmpty {
                players[currentIndex] = AVPlayer(url: URL(string: apiViewModel.myPostFeed[currentIndex].videoUrl ?? "")!)
                await players[currentIndex]?.seek(to: .zero)
                players[currentIndex]?.play()
              }
              apiViewModel.postFeedPlayerChanged()
              log("contentId: \(contentId)")
              log("currentIndex: \(currentIndex)")
              log("playerIndex: \(currentIndex)")
              await apiViewModel.deleteContent(contentId: contentId)
            } else {
              guard let contentId = apiViewModel.myPostFeed[currentIndex].contentId else { return }
              log("contentId: \(contentId)")
              log("currentIndex: \(currentIndex)")
              log("playerIndex: \(playerIndex)")
              apiViewModel.myPostFeed.removeLast()
              players.last??.pause()
              players.removeLast()
              currentIndex -= 1
              apiViewModel.postFeedPlayerChanged()
              log("contentId: \(contentId)")
              log("currentIndex: \(currentIndex)")
              log("playerIndex: \(currentIndex)")
              await apiViewModel.deleteContent(contentId: contentId)
            }
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
  }
}

extension MyContentListView {

  @ViewBuilder
  func userInfo(
    contentId: Int?,
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
              profileImageView(url: apiViewModel.myProfile.profileImage, size: 36)
                .padding(.trailing, 12)
              Text(apiViewModel.myProfile.userName)
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
        VStack(spacing: 28) {
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
                .font(.system(size: 30))
                .contentShape(Rectangle())
                .foregroundColor(.Gray10)
                .padding(.bottom, 2)
              Text("\(whistleCount.wrappedValue)")
                .foregroundColor(.Gray10)
                .fontSystem(fontDesignSystem: .subtitle3_KO)
                .padding(.bottom, 24)
            }
          }
          Button {
            showPasteToast = true
            UIPasteboard.general.setValue(
              "https://readywhistle.com/content_uni?contentId=\(apiViewModel.myPostFeed[currentIndex].contentId ?? 0)",
              forPasteboardType: UTType.plainText.identifier)
          } label: {
            Image(systemName: "square.and.arrow.up")
              .font(.system(size: 30))
              .contentShape(Rectangle())
              .foregroundColor(.Gray10)
          }
          .fontSystem(fontDesignSystem: .caption_Regular)
          Button {
            showDialog = true
          } label: {
            Image(systemName: "ellipsis")
              .font(.system(size: 30))
              .contentShape(Rectangle())
              .foregroundColor(.Gray10)
          }
        }
      }
    }
    .padding(.bottom, 64)
    .padding(.horizontal, 12)
  }
}

// MARK: - Timer
extension MyContentListView {
  func whistleToggle() {
    HapticManager.instance.impact(style: .medium)
    timer?.invalidate()
    if apiViewModel.myPostFeed[currentIndex].isWhistled == 1 {
      timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
        Task {
          await apiViewModel.actionWhistleCancel(contentId: apiViewModel.myPostFeed[currentIndex].contentId ?? 0)
        }
      }
      apiViewModel.myPostFeed[currentIndex].contentWhistleCount? -= 1
    } else {
      timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
        Task {
          await apiViewModel.actionWhistle(contentId: apiViewModel.myPostFeed[currentIndex].contentId ?? 0)
        }
      }
      apiViewModel.myPostFeed[currentIndex].contentWhistleCount! += 1
    }
    apiViewModel.myPostFeed[currentIndex].isWhistled = apiViewModel.myPostFeed[currentIndex].isWhistled == 1 ? 0 : 1
    apiViewModel.postFeedPlayerChanged()
  }
}
