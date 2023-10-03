//
//  MainView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/4/23.
//

import _AVKit_SwiftUI
import AVFoundation
import Kingfisher
import SwiftUI

// MARK: - MainView

struct MainView: View {

  @EnvironmentObject var apiViewModel: APIViewModel
  @EnvironmentObject var tabbarModel: TabbarModel
  @State var currentIndex = 0
  @State var playerIndex = 0
  @State var showDialog = false
  @State var showPasteToast = false
  @State var showBookmarkToast = false
  @State var showHideContentToast = false
  @State var showReport = false
  @State var showFollowToast = (false, "")
  @State var showUserProfile = false
  @State var currentVideoUserId = 0
  @State var currentVideoContentId = 0
  @State var isShowingBottomSheet = false
  @State var players: [AVPlayer?] = []
  @State var newId = UUID()
  @State var isCurrentVideoWhistled = false
  @State var timer: Timer? = nil
  @Binding var mainOpacity: Double

  var body: some View {
    GeometryReader { proxy in
      TabView(selection: $currentIndex) {
        ForEach(Array(apiViewModel.contentList.enumerated()), id: \.element) { index, content in
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
                      isFollowed:
                      Binding(get: {
                        content.isFollowed
                      }, set: { newValue in
                        content.isFollowed = newValue
                      }),
                      caption: content.caption ?? "",
                      musicTitle: content.musicTitle ?? "",
                      isWhistled: Binding(get: {
                        content.isWhistled
                      }, set: { newValue in
                        content.isWhistled = newValue
                      }),
                      whistleCount:
                      Binding(get: {
                        content.whistleCount ?? 0
                      }, set: { newValue in
                        content.whistleCount = newValue
                      }))
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
        if apiViewModel.contentList.isEmpty {
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
      if apiViewModel.myProfile.userName.isEmpty {
        await apiViewModel.requestMyProfile()
      }
      if apiViewModel.contentList.isEmpty {
        apiViewModel.requestContentList {
          Task {
            if !apiViewModel.contentList.isEmpty {
              for _ in 0..<apiViewModel.contentList.count {
                players.append(nil)
              }
              log(players)
              players[currentIndex] = AVPlayer(url: URL(string: apiViewModel.contentList[currentIndex].videoUrl ?? "")!)
              playerIndex = currentIndex
              guard let player = players[currentIndex] else {
                return
              }
              currentVideoUserId = apiViewModel.contentList[currentIndex].userId ?? 0
              currentVideoContentId = apiViewModel.contentList[currentIndex].contentId ?? 0
              isCurrentVideoWhistled = apiViewModel.contentList[currentIndex].isWhistled
              await player.seek(to: .zero)
              player.play()
            }
          }
        }
      }
    }
    .onChange(of: currentIndex) { newValue in
      guard let url = apiViewModel.contentList[newValue].videoUrl else {
        return
      }
      players[newValue] = AVPlayer(url: URL(string: url)!)
      players[playerIndex]?.seek(to: .zero)
      players[playerIndex]?.pause()
      players[playerIndex] = nil
      players[newValue]?.seek(to: .zero)
      players[newValue]?.play()
      playerIndex = newValue
      currentVideoUserId = apiViewModel.contentList[newValue].userId ?? 0
      currentVideoContentId = apiViewModel.contentList[newValue].contentId ?? 0
      apiViewModel.postFeedPlayerChanged()
    }
    .overlay {
      if showPasteToast {
        ToastMessage(text: "클립보드에 복사되었어요", paddingBottom: 78, showToast: $showPasteToast)
      }
      if showBookmarkToast {
        ToastMessage(text: "저장되었습니다!", paddingBottom: 78, showToast: $showBookmarkToast)
      }
      if showFollowToast.0 {
        ToastMessage(text: showFollowToast.1, paddingBottom: 78, showToast: $showFollowToast.0)
      }
      if showHideContentToast {
        CancelableToastMessage(text: "해당 콘텐츠를 숨겼습니다", paddingBottom: 78, action: {
          Task {
            await apiViewModel.actionContentHate(contentId: currentVideoContentId)
            apiViewModel.contentList.remove(at: currentIndex)
            guard let url = apiViewModel.contentList[currentIndex + 1].videoUrl else {
              return
            }
            apiViewModel.contentList[currentIndex + 1].player = AVPlayer(url: URL(string: url)!)
            await apiViewModel.contentList[currentIndex].player?.seek(to: .zero)
            apiViewModel.contentList[currentIndex].player?.play()
            apiViewModel.postFeedPlayerChanged()
          }
        }, showToast: $showHideContentToast)
      }
    }
    .confirmationDialog("", isPresented: $showDialog) {
      Button("저장하기", role: .none) {
        Task {
          showBookmarkToast = await apiViewModel.actionBookmark(contentId: currentVideoContentId)
        }
      }
      Button("관심없음", role: .none) {
        showHideContentToast = true
      }
      Button("신고", role: .destructive) {
        log(currentVideoContentId)
        showReport = true
      }
      Button("닫기", role: .cancel) {
        log("Cancel")
      }
    }
    .navigationDestination(isPresented: $showUserProfile) {
      UserProfileView(userId: currentVideoUserId)
        .environmentObject(apiViewModel)
        .environmentObject(tabbarModel)
    }
    .fullScreenCover(isPresented: $showReport) {
      MainReportReasonView(
        goReport: $showReport,
        contentId: currentVideoContentId,
        userId: currentVideoUserId)
        .environmentObject(apiViewModel)
    }
  }
}

extension MainView {
  @ViewBuilder
  func userInfo(
    contentId _: Int,
    userName: String,
    profileImg: String,
    isFollowed: Binding<Bool>,
    caption: String,
    musicTitle: String,
    isWhistled: Binding<Bool>,
    whistleCount: Binding<Int>)
    -> some View
  {
    VStack(spacing: 0) {
      Spacer()
      HStack(spacing: 0) {
        VStack(alignment: .leading, spacing: 12) {
          Spacer()
          HStack(spacing: 0) {
            Button {
              players[currentIndex]?.pause()
              showUserProfile = true
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
            if userName != apiViewModel.myProfile.userName {
              Button {
                Task {
                  if isFollowed.wrappedValue {
                    await apiViewModel.unfollowUser(userId: currentVideoUserId)
                    showFollowToast = (true, "\(userName)님을 팔로우 취소함")
                  } else {
                    await apiViewModel.followUser(userId: currentVideoUserId)
                    showFollowToast = (true, "\(userName)님을 팔로우 중")
                  }
                  isFollowed.wrappedValue.toggle()
                  apiViewModel.contentList = apiViewModel.contentList.map { item in
                    let mutableItem = item
                    if mutableItem.userId == currentVideoUserId {
                      mutableItem.isFollowed = isFollowed.wrappedValue
                    }
                    return mutableItem
                  }
                  apiViewModel.postFeedPlayerChanged()
                }
              } label: {
                Text(isFollowed.wrappedValue ? "following" : "follow")
                  .fontSystem(fontDesignSystem: .caption_SemiBold)
                  .foregroundColor(.Gray10)
                  .background {
                    Capsule()
                      .stroke(Color.Border_Default, lineWidth: 1)
                      .frame(width: isFollowed.wrappedValue ? 78 : 60, height: 26)
                  }
                  .frame(width: isFollowed.wrappedValue ? 78 : 60, height: 26)
              }
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
            whistleToggle()
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

// MARK: - Timer
extension MainView {
  func whistleToggle() {
    timer?.invalidate()
    if apiViewModel.contentList[currentIndex].isWhistled {
      timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
        Task {
          await apiViewModel.actionWhistleCancel(contentId: currentVideoContentId)
        }
      }
      apiViewModel.contentList[currentIndex].whistleCount? -= 1
    } else {
      timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
        Task {
          await apiViewModel.actionWhistle(contentId: currentVideoContentId)
        }
      }
      apiViewModel.contentList[currentIndex].whistleCount? += 1
    }
    apiViewModel.contentList[currentIndex].isWhistled.toggle()
    apiViewModel.postFeedPlayerChanged()
  }
}
