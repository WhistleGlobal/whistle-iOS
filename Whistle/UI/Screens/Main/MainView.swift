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

  @Environment(\.scenePhase) var scenePhase
  @EnvironmentObject var apiViewModel: APIViewModel
  @EnvironmentObject var tabbarModel: TabbarModel
  @EnvironmentObject var universalRoutingModel: UniversalRoutingModel
  @State var viewCount: ViewCount = .init()
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
  @State var viewTimer: Timer? = nil
  @State var isSplashOn = true
  @State var processedContentId: Set<Int> = []
  @Binding var mainOpacity: Double
  @Binding var isRootStacked: Bool

  var body: some View {
    GeometryReader { proxy in
      TabView(selection: $currentIndex) {
        ForEach(Array(apiViewModel.contentList.enumerated()), id: \.element) { index, content in
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
                .onAppear {
                  let dateFormatter = DateFormatter()
                  dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                  let dateString = dateFormatter.string(from: .now)
                  if let index = viewCount.views.firstIndex(where: { $0.contentId == content.contentId }) {
                    viewCount.views[index].viewDate = dateString
                  } else {
                    viewCount.views.append(.init(contentId: content.contentId ?? 0, viewDate: dateString))
                  }
                  log("viewCount.views: \(viewCount.views)")
                }
                .onDisappear {
                  if let index = viewCount.views.firstIndex(where: { $0.contentId == content.contentId }) {
                    let viewDate = viewCount.views[index].viewDate.toDate()
                    var nowDate = Date.now
                    nowDate.addTimeInterval(3600 * 9)
                    log("Date.now: \(nowDate)")
                    log("viewDate: \(viewDate)")
                    let viewTime = nowDate.timeIntervalSince(viewDate ?? Date.now)
                    log("viewTime: \(viewTime)")
                    viewCount.views[index].viewTime = "\(Int(viewTime))"
                    log("viewCount.views[index].viewTime : \(viewCount.views[index].viewTime)")
                  }
                }
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
        if apiViewModel.contentList.isEmpty, players.isEmpty {
          return
        }
        if players.count <= currentIndex {
          return
        }
        guard let player = players[currentIndex] else {
          return
        }
        if newValue == 1 {
          if !isRootStacked {
            log("play")
            player.play()
          }
        } else {
          player.pause()
          apiViewModel.addViewCount(viewCount, notInclude: processedContentId) { viewCountList in
            var tempSet: Set<Int> = []
            for view in viewCountList {
              tempSet.insert(view.contentId)
            }
            processedContentId = processedContentId.union(tempSet)
          }
        }
      }
    }
    .ignoresSafeArea(.all, edges: .top)
    .navigationBarBackButtonHidden()
    .background(.black)
    .task {
      log("task")
      if apiViewModel.myProfile.userName.isEmpty {
        await apiViewModel.requestMyProfile()
      }
      if apiViewModel.contentList.isEmpty {
        if universalRoutingModel.isUniversalContent {
          log("universalRoutingModel.isUniversalContent \(universalRoutingModel.isUniversalContent)")
          apiViewModel.requestUniversalContent(contentId: universalRoutingModel.contentId) {
            setupPlayers()
            universalRoutingModel.isUniversalContent = false
          }
        } else {
          apiViewModel.requestContentList {
            setupPlayers()
          }
        }
      }
    }
    .onChange(of: currentIndex) { newValue in
      if universalRoutingModel.isUniversalContent {
        return
      }
      guard let url = apiViewModel.contentList[newValue].videoUrl else {
        return
      }
      players[playerIndex]?.seek(to: .zero)
      players[playerIndex]?.pause()
      players[playerIndex] = nil
      players[newValue] = AVPlayer(url: URL(string: url)!)
      players[newValue]?.seek(to: .zero)
      players[newValue]?.play()
      playerIndex = newValue
      currentVideoUserId = apiViewModel.contentList[newValue].userId ?? 0
      currentVideoContentId = apiViewModel.contentList[newValue].contentId ?? 0
      apiViewModel.postFeedPlayerChanged()
    }
    .onChange(of: scenePhase) { newValue in
      switch newValue {
      case .background:
        apiViewModel.addViewCount(viewCount, notInclude: processedContentId) { viewCountList in
          var tempSet: Set<Int> = []
          for view in viewCountList {
            tempSet.insert(view.contentId)
          }
          processedContentId = processedContentId.union(tempSet)
        }
      default:
        log("default")
      }
    }
    .onChange(of: universalRoutingModel.isUniversalProfile) { newValue in
      if newValue {
        tabbarModel.tabSelectionNoAnimation = .main
        tabbarModel.tabSelection = .main
        isRootStacked = true
      }
    }
    .onChange(of: universalRoutingModel.isUniversalContent) { newValue in
      if newValue, !apiViewModel.contentList.isEmpty {
        tabbarModel.tabSelectionNoAnimation = .main
        tabbarModel.tabSelection = .main
        currentIndex = 0
        playerIndex = 0
        currentVideoUserId = 0
        currentVideoContentId = 0
        players.removeAll()
        apiViewModel.contentList.removeAll()
        if universalRoutingModel.isUniversalContent {
          apiViewModel.requestUniversalContent(contentId: universalRoutingModel.contentId) {
            setupPlayers()
            universalRoutingModel.isUniversalContent = false
          }
        } else {
          apiViewModel.requestContentList {
            setupPlayers()
            universalRoutingModel.isUniversalContent = false
          }
        }
      }
    }
    .overlay {
      if showPasteToast {
        ToastMessage(text: "클립보드에 복사되었어요", toastPadding: 70, isTopAlignment: true, showToast: $showPasteToast)
      }
      if showBookmarkToast {
        ToastMessage(text: "저장되었습니다!", toastPadding: 70, isTopAlignment: true, showToast: $showBookmarkToast)
      }
      if showFollowToast.0 {
        ToastMessage(text: showFollowToast.1, toastPadding: 70, isTopAlignment: true, showToast: $showFollowToast.0)
      }
      if showHideContentToast {
        CancelableToastMessage(text: "해당 콘텐츠를 숨겼습니다", paddingBottom: 78, action: {
          Task {
            await apiViewModel.actionContentHate(contentId: currentVideoContentId)
            apiViewModel.contentList.remove(at: currentIndex)
            guard let url = apiViewModel.contentList[currentIndex].videoUrl else {
              return
            }
            players[currentIndex] = AVPlayer(url: URL(string: url)!)
            await players[currentIndex]?.seek(to: .zero)
            players[currentIndex]?.play()
            apiViewModel.postFeedPlayerChanged()
          }
        }, showToast: $showHideContentToast)
      }
    }
    .onAppear {
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
        withAnimation {
          isSplashOn = false
        }
      }
    }
    .overlay {
      if isSplashOn {
        SignInPlayerView()
          .ignoresSafeArea()
          .allowsTightening(false)
          .onAppear {
            tabbarModel.tabbarOpacity = 0.0
          }
          .onDisappear {
            tabbarModel.tabbarOpacity = 1.0
          }
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
    .fullScreenCover(isPresented: $showReport) {
      MainReportReasonView(
        goReport: $showReport,
        contentId: currentVideoContentId,
        userId: currentVideoUserId)
        .environmentObject(apiViewModel)
    }
    .navigationDestination(isPresented: $isRootStacked) {
      if universalRoutingModel.isUniversalProfile {
        if UIDevice.current.userInterfaceIdiom == .phone {
          switch UIScreen.main.nativeBounds.height {
          case 1334: // iPhone SE 3rd generation
            SEUserProfileView(players: $players, currentIndex: $currentIndex, userId: universalRoutingModel.userId)
              .environmentObject(apiViewModel)
              .environmentObject(tabbarModel)
              .onDisappear {
                universalRoutingModel.isUniversalProfile = false
              }
          default:
            UserProfileView(players: $players, currentIndex: $currentIndex, userId: universalRoutingModel.userId)
              .environmentObject(apiViewModel)
              .environmentObject(tabbarModel)
              .onDisappear {
                universalRoutingModel.isUniversalProfile = false
              }
          }
        }
      } else {
        if UIDevice.current.userInterfaceIdiom == .phone {
          switch UIScreen.main.nativeBounds.height {
          case 1334: // iPhone SE 3rd generation
            SEUserProfileView(players: $players, currentIndex: $currentIndex, userId: currentVideoUserId)
              .environmentObject(apiViewModel)
              .environmentObject(tabbarModel)
          default:
            UserProfileView(players: $players, currentIndex: $currentIndex, userId: currentVideoUserId)
              .environmentObject(apiViewModel)
              .environmentObject(tabbarModel)
          }
        }
      }
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
            if apiViewModel.contentList[currentIndex].userName != apiViewModel.myProfile.userName {
              Button {
                isRootStacked = true
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
            } else {
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
              "https://readywhistle.com/content_uni?contentId=\(currentVideoContentId)",
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
    .padding(.bottom, 64)
    .padding(.horizontal, 20)
  }
}

// MARK: - Timer
extension MainView {
  func whistleToggle() {
    HapticManager.instance.impact(style: .medium)
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

extension String {
  func toDate() -> Date? { // "yyyy-MM-dd HH:mm:ss"
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.timeZone = TimeZone(identifier: "UTC")
    if let date = dateFormatter.date(from: self) {
      return date
    } else {
      return nil
    }
  }
}

extension Date {
  func toString() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.timeZone = TimeZone(identifier: "UTC")
    return dateFormatter.string(from: self)
  }
}

extension MainView {
  func setupPlayers() {
    Task {
      if !apiViewModel.contentList.isEmpty {
        players.removeAll()
        for _ in 0..<apiViewModel.contentList.count {
          players.append(nil)
        }
        log(players)
        players[currentIndex] =
          AVPlayer(url: URL(string: apiViewModel.contentList[currentIndex].videoUrl ?? "")!)
        playerIndex = currentIndex
        guard let player = players[currentIndex] else {
          return
        }
        currentVideoUserId = apiViewModel.contentList[currentIndex].userId ?? 0
        currentVideoContentId = apiViewModel.contentList[currentIndex].contentId ?? 0
        isCurrentVideoWhistled = apiViewModel.contentList[currentIndex].isWhistled
        await player.seek(to: .zero)
        player.play()
        withAnimation {
          isSplashOn = false
        }
        if universalRoutingModel.isUniversalProfile {
          isRootStacked = true
        }
      }
    }
  }
}
