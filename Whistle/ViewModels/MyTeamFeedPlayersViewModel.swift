//
//  MyTeamFeedPlayersViewModel.swift
//  Whistle
//
//  Created by ChoiYujin on 11/22/23.
//

import AVFoundation

// FIXME: - MyTeam API 나오면 고쳐보기

class MyTeamFeedPlayersViewModel: ObservableObject {

  static let shared = MyTeamFeedPlayersViewModel()
  private init() { }

  @Published var prevPlayer: AVPlayer?
  @Published var currentPlayer: AVPlayer?
  @Published var nextPlayer: AVPlayer?
  @Published var apiViewModel = APIViewModel.shared
  @Published var currentVideoIndex = 0

  func goPlayerNext() {
    let index = min(max(0, currentVideoIndex), apiViewModel.myTeamFeed.count - 1)
    if index == apiViewModel.myTeamFeed.count - 1 {
      stopPlayer()
      prevPlayer = nil
      prevPlayer = currentPlayer
      currentPlayer = nextPlayer
      nextPlayer = nil
      currentPlayer?.seek(to: .zero)
      if BlockList.shared.userIds.contains(apiViewModel.myTeamFeed[currentVideoIndex].userId ?? 0) {
        return
      }
      currentPlayer?.play()
    } else {
      stopPlayer()
      prevPlayer = nil
      prevPlayer = currentPlayer
      currentPlayer = nextPlayer
      nextPlayer = nil
      nextPlayer = AVPlayer(url: URL(string: apiViewModel.myTeamFeed[index + 1].videoUrl ?? "")!)
      currentPlayer?.seek(to: .zero)
      if BlockList.shared.userIds.contains(apiViewModel.myTeamFeed[currentVideoIndex].userId ?? 0) {
        return
      }
      currentPlayer?.play()
    }
  }

  func goPlayerPrev() {
    if currentVideoIndex == 0 {
      stopPlayer()
      nextPlayer = nil
      nextPlayer = currentPlayer
      currentPlayer = nil
      currentPlayer = prevPlayer
      prevPlayer = nil
      currentPlayer?.seek(to: .zero)
      if BlockList.shared.userIds.contains(apiViewModel.myTeamFeed[currentVideoIndex].userId ?? 0) {
        return
      }
      currentPlayer?.play()
      return
    }
    stopPlayer()
    nextPlayer = nil
    nextPlayer = currentPlayer
    currentPlayer = nil
    currentPlayer = prevPlayer
    prevPlayer = nil
    if currentVideoIndex != 0 {
      prevPlayer = AVPlayer(url: URL(string: apiViewModel.myTeamFeed[currentVideoIndex - 1].videoUrl ?? "")!)
    }
    currentPlayer?.seek(to: .zero)
    if BlockList.shared.userIds.contains(apiViewModel.myTeamFeed[currentVideoIndex].userId ?? 0) {
      return
    }
    currentPlayer?.play()
  }

  func stopPlayer() {
    if prevPlayer != nil {
      prevPlayer?.seek(to: .zero)
      prevPlayer?.pause()
    }
    if currentPlayer != nil {
      currentPlayer?.seek(to: .zero)
      currentPlayer?.pause()
    }
    if nextPlayer != nil {
      nextPlayer?.seek(to: .zero)
      nextPlayer?.pause()
    }
  }

  func resetPlayer() {
    prevPlayer = nil
    currentPlayer = nil
    nextPlayer = nil
  }

  func initialPlayers() {
    if apiViewModel.myTeamFeed.isEmpty { return }
    guard let urlString = apiViewModel.myTeamFeed.first?.videoUrl else { return }
    currentPlayer = AVPlayer(url: URL(string: urlString)!)
    if apiViewModel.myTeamFeed.count < 2 { return }
    guard let urlStringNext = apiViewModel.myTeamFeed[1].videoUrl else { return }
    nextPlayer = AVPlayer(url: URL(string: urlStringNext)!)
  }

  func removePlayer(completion: @escaping () -> Void) {
    stopPlayer()
    if apiViewModel.myTeamFeed.count == 1 {
      apiViewModel.myTeamFeed.removeAll()
      prevPlayer = nil
      currentPlayer = nil
      nextPlayer = nil
      return
    }
    if apiViewModel.myTeamFeed.count == 2, currentVideoIndex == 0 {
      currentPlayer = nil
      currentPlayer = nextPlayer
      apiViewModel.myTeamFeed.remove(at: currentVideoIndex)
      nextPlayer = AVPlayer(url: URL(string: apiViewModel.myTeamFeed[currentVideoIndex].videoUrl ?? "")!)
      currentPlayer?.seek(to: .zero)
      if BlockList.shared.userIds.contains(apiViewModel.myTeamFeed[currentVideoIndex].userId ?? 0) {
        return
      }
      currentPlayer?.play()
      return
    }
    if currentVideoIndex == apiViewModel.myTeamFeed.count - 1 {
      currentPlayer = nil
      currentPlayer = prevPlayer
      apiViewModel.myTeamFeed.removeLast()
      currentVideoIndex -= 1
      if currentVideoIndex == 0 {
        prevPlayer = nil
      } else {
        prevPlayer = AVPlayer(url: URL(string: apiViewModel.myTeamFeed[currentVideoIndex - 1].videoUrl ?? "")!)
      }
      currentPlayer?.seek(to: .zero)
      if BlockList.shared.userIds.contains(apiViewModel.myTeamFeed[currentVideoIndex].userId ?? 0) {
        return
      }
      currentPlayer?.play()
      completion()
    } else {
      currentPlayer = nil
      currentPlayer = nextPlayer
      apiViewModel.myTeamFeed.remove(at: currentVideoIndex)
      nextPlayer = AVPlayer(url: URL(string: apiViewModel.myTeamFeed[currentVideoIndex + 1].videoUrl ?? "")!)
      currentPlayer?.seek(to: .zero)
      if BlockList.shared.userIds.contains(apiViewModel.myTeamFeed[currentVideoIndex].userId ?? 0) {
        return
      }
      currentPlayer?.play()
    }
  }
}
