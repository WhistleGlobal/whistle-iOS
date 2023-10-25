//
//  MemberFeedView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/21/23.
//

import AVFoundation
import Kingfisher
import SwiftUI

// MARK: - MemberFeedView

struct MemberFeedView: View {
  @Environment(\.dismiss) var dismiss
  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject private var tabbarModel = TabbarModel.shared
  @StateObject private var toastViewModel = ToastViewModel.shared

  @State var currentIndex = 0
  @State var currentVideoIsBookmarked = false
  @State var newID = UUID()
  @State var playerIndex = 0
  @State var players: [AVPlayer?] = []

  @State var showDialog = false
  @State var showPlayButton = false
  @State var showHideContentToast = false
  @State var showReport = false

  @State var timer: Timer? = nil

  let processor = BlurImageProcessor(blurRadius: 100.0)
  var body: some View {
    GeometryReader { proxy in
      TabView(selection: $currentIndex) {
        ForEach(Array(apiViewModel.memberFeed.enumerated()), id: \.element) { index, content in
          if !players.isEmpty {
            if let player = players[index] {
              ContentPlayer(player: player)
                .frame(width: UIScreen.width)
                .opacity(content.isHated ? 0.1 : 1)
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
                      content.isWhistled
                    }, set: { newValue in
                      content.isWhistled = newValue
                    }),
                    isHated: content.isHated,
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
                .overlay {
                  if content.isHated {
                    KFImage.url(URL(string: content.thumbnailUrl ?? ""))
                      .placeholder {
                        Color.black
                      }
                      .resizable()
                      .setProcessor(processor)
                      .scaledToFill()
                      .frame(width: UIScreen.width, height: UIScreen.height)
                      .overlay(alignment: .topLeading) {
                        Button {
                          players[currentIndex]?.pause()
                          players.removeAll()
                          dismiss()
                        } label: {
                          Image(systemName: "chevron.backward")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 16)
                            .padding(.leading, 8)
                        }
                        .padding(.top, 54)
                      }
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
                          Text("관심없음을 설정한 모든 콘텐츠는 회원님의 피드에 노출되지 않습니다.")
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(nil)
                            .multilineTextAlignment(.center)
                            .fontSystem(fontDesignSystem: .body2_KO)
                            .foregroundColor(.LabelColor_Secondary_Dark)
                            .padding(.horizontal, 80)
                        }
                        .ignoresSafeArea()
                      }
                  }
                }
                .rotationEffect(Angle(degrees: -90))
                .ignoresSafeArea(.all)
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
      .frame(width: UIScreen.height)
      .tabViewStyle(.page(indexDisplayMode: .never))
      .frame(maxWidth: UIScreen.height)
      .offset(x: -UIScreen.height / 4 - 16)
      .ignoresSafeArea(.all)

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
            .padding(.top, 68)
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
    .ignoresSafeArea(.all)
    .navigationBarBackButtonHidden()
    .background(.black)
    .onAppear {
      for _ in 0 ..< apiViewModel.memberFeed.count {
        players.append(nil)
      }
      players[currentIndex] = AVPlayer(url: URL(string: apiViewModel.memberFeed[currentIndex].videoUrl ?? "")!)
      playerIndex = currentIndex
      currentVideoIsBookmarked = apiViewModel.memberFeed[currentIndex].isBookmarked
      players[currentIndex]?.seek(to: .zero)
      if !apiViewModel.memberFeed[currentIndex].isHated {
        players[currentIndex]?.play()
      }
      apiViewModel.postFeedPlayerChanged()
    }
    .onChange(of: currentIndex) { newValue in
      if apiViewModel.memberFeed.isEmpty {
        return
      }
      guard let url = apiViewModel.memberFeed[newValue].videoUrl else {
        return
      }
      players[newValue] = AVPlayer(url: URL(string: url)!)
      if playerIndex < players.count {
        players[playerIndex]?.seek(to: .zero)
        players[playerIndex]?.pause()
        players[playerIndex] = nil
      }
      currentVideoIsBookmarked = apiViewModel.memberFeed[newValue].isBookmarked
      players[newValue]?.seek(to: .zero)
      if !apiViewModel.memberFeed[currentIndex].isHated {
        players[currentIndex]?.play()
      }
      playerIndex = newValue
      apiViewModel.postFeedPlayerChanged()
    }
    .overlay {
      ToastMessageView()
//      if showHideContentToast {
//        CancelableToastMessage(text: "해당 콘텐츠를 숨겼습니다", paddingBottom: 78, action: {
//          Task {
//            guard let contentId = apiViewModel.memberFeed[currentIndex].contentId else { return }
//            apiViewModel.memberFeed[currentIndex].isHated = true
//            players[currentIndex]?.pause()
//            apiViewModel.postFeedPlayerChanged()
//            await apiViewModel.actionContentHate(contentID: contentId)
//          }
//        }, showToast: $showHideContentToast)
//      }
    }
    .fullScreenCover(isPresented: $showReport) {
      MainFeedReportReasonSelectionView(
        goReport: $showReport,
        contentId: apiViewModel.memberFeed[currentIndex].contentId ?? 0,
        userId: apiViewModel.memberFeed[currentIndex].userId ?? 0)
    }
    .confirmationDialog("", isPresented: $showDialog) {
      Button(currentVideoIsBookmarked ? "저장 취소" : "저장하기", role: .none) {
        Task {
          guard apiViewModel.memberFeed[currentIndex].contentId != nil else { return }
          guard let currentVideocontentId = apiViewModel.memberFeed[currentIndex].contentId else { return }
          if apiViewModel.memberFeed[currentIndex].isBookmarked {
            if await apiViewModel.bookmarkAction(contentID: currentVideocontentId, method: .delete) {
              toastViewModel.toastInit(message: "저장 취소 했습니다.")
            }
            apiViewModel.memberFeed[currentIndex].isBookmarked = false
            currentVideoIsBookmarked = false
          } else {
            if await apiViewModel.bookmarkAction(contentID: currentVideocontentId, method: .post) {
              toastViewModel.toastInit(message: "저장했습니다.")
            }
            apiViewModel.memberFeed[currentIndex].isBookmarked = true
            currentVideoIsBookmarked = true
          }
          apiViewModel.postFeedPlayerChanged()
        }
      }
      Button("관심없음", role: .none) {
        showHideContentToast = true
        toastViewModel.cancelToastInit(message: "해당 콘텐츠를 숨겼습니다") {
          Task {
            guard let contentId = apiViewModel.memberFeed[currentIndex].contentId else { return }
            apiViewModel.memberFeed[currentIndex].isHated = true
            players[currentIndex]?.pause()
            apiViewModel.postFeedPlayerChanged()
            await apiViewModel.actionContentHate(contentID: contentId)
          }
        }
      }
      Button("신고", role: .destructive) {
        showReport = true
      }
      Button("닫기", role: .cancel) { }
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

extension MemberFeedView {
  @ViewBuilder
  func userInfo(
    contentId _: Int?,
    userName: String,
    profileImg: String,
    thumbnailUrl _: String,
    caption: String,
    musicTitle: String,
    isWhistled: Binding<Bool>,
    isHated: Bool,
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
            .padding(.leading, 8)
        }
        Spacer()
      }
      .padding(.top, 54)

      if !isHated {
        Spacer()
        HStack(spacing: 0) {
          VStack(alignment: .leading, spacing: 12) {
            Spacer()
            HStack(spacing: 0) {
              Group {
                profileImageView(url: profileImg, size: 36)
                  .padding(.trailing, 16)
                Text(userName)
                  .foregroundColor(.white)
                  .fontSystem(fontDesignSystem: .subtitle1)
                  .padding(.trailing, 16)
              }
              Button {
                Task {
                  if apiViewModel.memberProfile.isFollowed {
                    await apiViewModel.followAction(userID: apiViewModel.memberProfile.userId, method: .delete)
                    apiViewModel.memberProfile.isFollowed = false
                    toastViewModel.toastInit(message: "\(userName)님을 팔로우 취소함")
                  } else {
                    await apiViewModel.followAction(userID: apiViewModel.memberProfile.userId, method: .post)
                    toastViewModel.toastInit(message: "\(userName)님을 팔로우 중")
                    apiViewModel.memberProfile.isFollowed = true
                  }
                  apiViewModel.memberFeed = apiViewModel.memberFeed.map { item in
                    let mutableItem = item
                    if mutableItem.userId == apiViewModel.memberProfile.userId {
                      mutableItem.isFollowed = apiViewModel.memberProfile.isFollowed
                    }
                    return mutableItem
                  }
                  apiViewModel.postFeedPlayerChanged()
                }
              } label: {
                Text(apiViewModel.memberProfile.isFollowed ? "팔로잉" : "팔로워")
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
              whistleToggle()
            } label: {
              VStack(spacing: 0) {
                Image(systemName: isWhistled.wrappedValue ? "heart.fill" : "heart")
                  .font(.system(size: 30))
                  .contentShape(Rectangle())
                  .foregroundColor(.Gray10)
                  .frame(width: 36, height: 36)
                Text("\(whistleCount.wrappedValue)")
                  .foregroundColor(.Gray10)
                  .fontSystem(fontDesignSystem: .subtitle3_KO)
              }
            }
            .padding(.bottom, -4)
            Button {
              guard let contentId = apiViewModel.memberFeed[currentIndex].contentId else {
                return
              }
              toastViewModel.toastInit(message: "클립보드에 복사되었어요")
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
    }
    .padding(.bottom, UIScreen.getHeight(98))
    .padding(.trailing, UIScreen.getWidth(12))
    .padding(.leading, UIScreen.getWidth(16))
  }
}

// MARK: - Timer

extension MemberFeedView {
  func whistleToggle() {
    HapticManager.instance.impact(style: .medium)
    timer?.invalidate()
    guard let contentId = apiViewModel.memberFeed[currentIndex].contentId else {
      return
    }
    if apiViewModel.memberFeed[currentIndex].isWhistled {
      timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
        Task {
          await apiViewModel.whistleAction(contentID: contentId, method: .delete)
        }
      }
      apiViewModel.memberFeed[currentIndex].contentWhistleCount! -= 1
    } else {
      timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
        Task {
          await apiViewModel.whistleAction(contentID: contentId, method: .post)
        }
      }
      apiViewModel.memberFeed[currentIndex].contentWhistleCount! += 1
    }
    if !apiViewModel.memberFeed[currentIndex].isWhistled {
      apiViewModel.memberFeed[currentIndex].isWhistled = true
    } else {
      apiViewModel.memberFeed[currentIndex].isWhistled = false
    }
    apiViewModel.postFeedPlayerChanged()
  }
}
