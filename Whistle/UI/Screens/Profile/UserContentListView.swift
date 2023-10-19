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
  @State var currentVideoIsBookmarked = false
  @State var newID = UUID()
  @State var playerIndex = 0
  @State var showDialog = false
  @State var showPasteToast = false
  @State var showDeleteToast = false
  @State var showBookmarkToast = (false, "저장하기")
  @State var showPlayButton = false
  @State var showHideContentToast = false
  @State var showReport = false
  @State var showFollowToast = (false, "")
  @State var players: [AVPlayer?] = []
  @State var timer: Timer? = nil

  var body: some View {
    GeometryReader { proxy in
      TabView(selection: $currentIndex) {
        ForEach(Array(apiViewModel.userPostFeed.enumerated()), id: \.element) { index, content in
          if !players.isEmpty {
            if let player = players[index] {
              Player(player: player)
                .frame(width: proxy.size.width)
                .opacity(content.isHated ?? 0 == 1 ? 0.1 : 1)
                .onChange(of: tabbarModel.tabSelectionNoAnimation) { newValue in
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
                    contentId: content.contentId ?? 0,
                    userName: content.userName ?? "",
                    profileImg: content.profileImg ?? "",
                    thumbnailUrl: content.thumbnailUrl ?? "",
                    caption: content.caption ?? "",
                    musicTitle: content.musicTitle ?? "원본 오디오",
                    isWhistled:
                    Binding(get: {
                      content.isWhistled == 1 ? true : false
                    }, set: { newValue in
                      content.isWhistled = newValue ? 1 : 0
                    }),
                    isHated: content.isHated ?? 0,
                    whistleCount:
                    Binding(get: {
                      content.contentWhistleCount ?? 0
                    }, set: { newValue in
                      content.contentWhistleCount = newValue
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
              Color.black
                .tag(index)
                .frame(width: proxy.size.width)
                .padding()
                .rotationEffect(Angle(degrees: -90))
                .ignoresSafeArea(.all, edges: .top)
//              KFImage.url(URL(string: content.thumbnailUrl ?? ""))
//                .placeholder {
//                  Color.black
//                }
//                .resizable()
//                .scaledToFill()
//                .tag(index)
//                .frame(width: proxy.size.width)
//                .padding()
//                .rotationEffect(Angle(degrees: -90))
//                .ignoresSafeArea(.all, edges: .top)
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

      if players.isEmpty {
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
      }
    }
    .ignoresSafeArea(.all, edges: .top)
    .navigationBarBackButtonHidden()
    .background(.black)
    .onAppear {
      log("currentIndex : \(currentIndex)")
      for _ in 0 ..< apiViewModel.userPostFeed.count {
        players.append(nil)
      }
      players[currentIndex] = AVPlayer(url: URL(string: apiViewModel.userPostFeed[currentIndex].videoUrl ?? "")!)
      playerIndex = currentIndex
      currentVideoIsBookmarked = apiViewModel.userPostFeed[currentIndex].isBookmarked == 1
      players[currentIndex]?.seek(to: .zero)
      if !(apiViewModel.userPostFeed[currentIndex].isHated == 1) {
        players[currentIndex]?.play()
      }
      apiViewModel.postFeedPlayerChanged()
    }
    .onChange(of: currentIndex) { newValue in
      if apiViewModel.userPostFeed.isEmpty {
        return
      }
      log(playerIndex)
      log(newValue)
      log(currentIndex)
      guard let url = apiViewModel.userPostFeed[newValue].videoUrl else {
        return
      }
      players[newValue] = AVPlayer(url: URL(string: url)!)
      if playerIndex < players.count {
        players[playerIndex]?.seek(to: .zero)
        players[playerIndex]?.pause()
        players[playerIndex] = nil
      }
      currentVideoIsBookmarked = apiViewModel.userPostFeed[newValue].isBookmarked == 1
      players[newValue]?.seek(to: .zero)
      if !(apiViewModel.userPostFeed[currentIndex].isHated == 1) {
        players[currentIndex]?.play()
      }
      playerIndex = newValue
      apiViewModel.postFeedPlayerChanged()
    }
    .overlay {
      if showPasteToast {
        ToastMessage(text: "클립보드에 복사되었어요", toastPadding: 70, isTopAlignment: true, showToast: $showPasteToast)
      }
      if showBookmarkToast.0 {
        ToastMessage(text: showBookmarkToast.1, toastPadding: 70, isTopAlignment: true, showToast: $showBookmarkToast.0)
      }
      if showFollowToast.0 {
        ToastMessage(text: showFollowToast.1, toastPadding: 70, isTopAlignment: true, showToast: $showFollowToast.0)
      }
      if showHideContentToast {
        CancelableToastMessage(text: "해당 콘텐츠를 숨겼습니다", paddingBottom: 78, action: {
          Task {
            if apiViewModel.userPostFeed.count - 1 != currentIndex { // 삭제하려는 컨텐츠가 배열 마지막이 아님
              guard let contentId = apiViewModel.userPostFeed[currentIndex].contentId else { return }
              log("contentId: \(contentId)")
              log("currentIndex: \(currentIndex)")
              log("playerIndex: \(playerIndex)")
              apiViewModel.userPostFeed.remove(at: currentIndex)
              players[currentIndex]?.pause()
              players.remove(at: currentIndex)
              if !players.isEmpty {
                players[currentIndex] =
                  AVPlayer(url: URL(string: apiViewModel.userPostFeed[currentIndex].videoUrl ?? "")!)
                await players[currentIndex]?.seek(to: .zero)
                players[currentIndex]?.play()
              }
              apiViewModel.postFeedPlayerChanged()
              log("contentId: \(contentId)")
              log("currentIndex: \(currentIndex)")
              log("playerIndex: \(currentIndex)")
              await apiViewModel.actionContentHate(contentId: contentId)
            } else {
              guard let contentId = apiViewModel.userPostFeed[currentIndex].contentId else { return }
              log("contentId: \(contentId)")
              log("currentIndex: \(currentIndex)")
              log("playerIndex: \(playerIndex)")
              apiViewModel.userPostFeed.removeLast()
              players.last??.pause()
              players.removeLast()
              currentIndex -= 1
              apiViewModel.postFeedPlayerChanged()
              log("contentId: \(contentId)")
              log("currentIndex: \(currentIndex)")
              log("playerIndex: \(currentIndex)")
              await apiViewModel.actionContentHate(contentId: contentId)
            }
          }
        }, showToast: $showHideContentToast)
      }
    }
    .fullScreenCover(isPresented: $showReport) {
      MainReportReasonView(
        goReport: $showReport,
        contentId: apiViewModel.userPostFeed[currentIndex].contentId ?? 0,
        userId: apiViewModel.userPostFeed[currentIndex].userId ?? 0)
        .environmentObject(apiViewModel)
    }
    .confirmationDialog("", isPresented: $showDialog) {
      Button(currentVideoIsBookmarked ? "저장 취소" : "저장하기", role: .none) {
        Task {
          guard let contentId = apiViewModel.userPostFeed[currentIndex].contentId else { return }
          guard let currentVideocontentId = apiViewModel.userPostFeed[currentIndex].contentId else { return }
          if apiViewModel.userPostFeed[currentIndex].isBookmarked == 1 {
            showBookmarkToast.1 = "저장 취소 했습니다."
            showBookmarkToast.0 = await apiViewModel.actionBookmarkCancel(contentId: currentVideocontentId)
            apiViewModel.userPostFeed[currentIndex].isBookmarked = 0
            currentVideoIsBookmarked = false
          } else {
            showBookmarkToast.1 = "저장했습니다."
            showBookmarkToast.0 = await apiViewModel.actionBookmark(contentId: currentVideocontentId)
            apiViewModel.userPostFeed[currentIndex].isBookmarked = 1
            currentVideoIsBookmarked = true
          }
          apiViewModel.postFeedPlayerChanged()
        }
      }
      Button("관심없음", role: .none) {
        showHideContentToast = true
      }
      Button("신고", role: .destructive) {
        showReport = true
      }
      Button("닫기", role: .cancel) {
        log("Cancel")
      }
    }
    .onDisappear {
      if players.count <= currentIndex {
        return
      }
      if players.isEmpty { return }
      guard let player = players[min(max(0, currentIndex), players.count - 1)] else {
        return
      }
      player.pause()
    }
  }
}

extension UserContentListView {
  @ViewBuilder
  func userInfo(
    contentId _: Int?,
    userName: String,
    profileImg: String,
    thumbnailUrl: String,
    caption: String,
    musicTitle: String,
    isWhistled: Binding<Bool>,
    isHated: Int,
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

      if isHated == 1 {
        Spacer()
        KFImage.url(URL(string: thumbnailUrl))
          .placeholder {
            Color.black
          }
          .resizable()
          .scaledToFit()
          .padding()
          .blur(radius: 30)
          .overlay {
            VStack {
              Image(systemName: "eye.slash.fill")
                .font(.system(size: 44))
                .foregroundColor(.Gray10)
                .padding(.bottom, 26)
              Text("관심없음을 설정한 콘텐츠입니다.")
                .fontSystem(fontDesignSystem: .subtitle1_KO)
                .foregroundColor(.LabelColor_Primary_Dark)
                .padding(.bottom, 12)
              Text("관심없음을 설정한 모든 콘텐츠는 \n회원님의 피드에 노출되지 않습니다.")
                .fontSystem(fontDesignSystem: .body2_KO)
                .foregroundColor(.LabelColor_Secondary_Dark)
            }
          }
        Spacer()
      } else {
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
              Button {
                Task {
                  if apiViewModel.userProfile.isFollowed == 1 {
                    await apiViewModel.unfollowUser(userId: apiViewModel.userProfile.userId)
                    apiViewModel.userProfile.isFollowed = 0
                    showFollowToast = (true, "\(userName)님을 팔로우 취소함")
                  } else {
                    await apiViewModel.followUser(userId: apiViewModel.userProfile.userId)
                    showFollowToast = (true, "\(userName)님을 팔로우 중")
                    apiViewModel.userProfile.isFollowed = 1
                  }
                  apiViewModel.userPostFeed = apiViewModel.userPostFeed.map { item in
                    let mutableItem = item
                    if mutableItem.userId == apiViewModel.userProfile.userId {
                      mutableItem.isFollowed = apiViewModel.userProfile.isFollowed
                    }
                    return mutableItem
                  }
                  apiViewModel.postFeedPlayerChanged()
                }
              } label: {
                Text(apiViewModel.userProfile.isFollowed == 1 ? "팔로잉" : "팔로워")
                  .fontSystem(fontDesignSystem: .caption_SemiBold)
                  .foregroundColor(.Gray10)
                  .background {
                    Capsule()
                      .stroke(Color.Gray10, lineWidth: 1)
                      .frame(width: 58, height: 26)
                  }
                  .frame(width: 58, height: 26)
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
              whistleToggle()
            } label: {
              VStack(spacing: 0) {
                Image(systemName: isWhistled.wrappedValue ? "heart.fill" : "heart")
                  .font(.system(size: 30))
                  .contentShape(Rectangle())
                  .foregroundColor(.Gray10)
                  .frame(width: 36, height: 36)
                  .padding(.bottom, 2)
                Text("\(whistleCount.wrappedValue)")
                  .foregroundColor(.Gray10)
                  .fontSystem(fontDesignSystem: .subtitle3_KO)
              }
            }
            .frame(width: 36, height: 36)
            Button {
              guard let contentId = apiViewModel.userPostFeed[currentIndex].contentId else {
                return
              }
              showPasteToast = true
              UIPasteboard.general.setValue(
                "https://readywhistle.com/content_uni?contentId=\(contentId)",
                forPasteboardType: UTType.plainText.identifier)
            } label: {
              Image(systemName: "square.and.arrow.up")
                .font(.system(size: 30))
                .contentShape(Rectangle())
                .foregroundColor(.Gray10)
                .frame(width: 36, height: 36)
            }
            .fontSystem(fontDesignSystem: .caption_Regular)
            .frame(width: 36, height: 36)
            Button {
              showDialog = true
            } label: {
              Image(systemName: "ellipsis")
                .font(.system(size: 30))
                .contentShape(Rectangle())
                .foregroundColor(.Gray10)
                .frame(width: 36, height: 36)
            }
            .frame(width: 36, height: 36)
          }
        }
      }
    }
    .padding(.bottom, 64)
    .padding(.horizontal, 12)
  }
}

// MARK: - Timer

extension UserContentListView {
  func whistleToggle() {
    HapticManager.instance.impact(style: .medium)
    timer?.invalidate()
    guard let contentId = apiViewModel.userPostFeed[currentIndex].contentId else {
      return
    }
    if apiViewModel.userPostFeed[currentIndex].isWhistled! == 1 {
      timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
        Task {
          await apiViewModel.actionWhistleCancel(contentId: contentId)
        }
      }
      apiViewModel.userPostFeed[currentIndex].contentWhistleCount! -= 1
    } else {
      timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
        Task {
          await apiViewModel.actionWhistle(contentId: contentId)
        }
      }
      apiViewModel.userPostFeed[currentIndex].contentWhistleCount! += 1
    }
    if apiViewModel.userPostFeed[currentIndex].isWhistled! == 0 {
      apiViewModel.userPostFeed[currentIndex].isWhistled = 1
    } else {
      apiViewModel.userPostFeed[currentIndex].isWhistled = 0
    }
    apiViewModel.postFeedPlayerChanged()
  }
}
