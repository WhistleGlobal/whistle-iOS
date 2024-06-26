//
//  FeedPlayersViewModel.swift
//  Whistle
//
//  Created by ChoiYujin on 10/26/23.
//

import AVFoundation

class MainFeedPlayersViewModel: ObservableObject {

  static let shared = MainFeedPlayersViewModel()
  private init() { }

  @Published var prevPlayer: AVPlayer?
  @Published var currentPlayer: AVPlayer?
  @Published var nextPlayer: AVPlayer?
  @Published var apiViewModel = APIViewModel.shared
  @Published var currentVideoIndex = 0

  func goPlayerNext() {
    let index = min(max(0, currentVideoIndex), apiViewModel.mainFeed.count - 1)
    if index == apiViewModel.mainFeed.count - 1 {
      stopPlayer()
      prevPlayer = nil
      prevPlayer = currentPlayer
      currentPlayer = nextPlayer
      nextPlayer = nil
      currentPlayer?.seek(to: .zero)
      if BlockList.shared.userIds.contains(apiViewModel.mainFeed[currentVideoIndex].userId ?? 0) {
        return
      }
      currentPlayer?.play()
    } else {
      stopPlayer()
      prevPlayer = nil
      prevPlayer = currentPlayer
      currentPlayer = nextPlayer
      nextPlayer = nil
      nextPlayer = AVPlayer(url: URL(string: apiViewModel.mainFeed[index + 1].videoUrl ?? "")!)
      currentPlayer?.seek(to: .zero)
      if BlockList.shared.userIds.contains(apiViewModel.mainFeed[currentVideoIndex].userId ?? 0) {
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
      if BlockList.shared.userIds.contains(apiViewModel.mainFeed[currentVideoIndex].userId ?? 0) {
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
      prevPlayer = AVPlayer(url: URL(string: apiViewModel.mainFeed[currentVideoIndex - 1].videoUrl ?? "")!)
    }
    currentPlayer?.seek(to: .zero)
    if BlockList.shared.userIds.contains(apiViewModel.mainFeed[currentVideoIndex].userId ?? 0) {
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
    if apiViewModel.mainFeed.isEmpty { return }
    guard let urlString = apiViewModel.mainFeed.first?.videoUrl else { return }
    currentPlayer = AVPlayer(url: URL(string: urlString)!)
    if apiViewModel.mainFeed.count < 2 { return }
    guard let urlStringNext = apiViewModel.mainFeed[1].videoUrl else { return }
    nextPlayer = AVPlayer(url: URL(string: urlStringNext)!)
  }

  func initialPlayers(index: Int) {
    WhistleLogger.logger.debug("initialPlayers(index: \(index))")
    if apiViewModel.mainFeed.isEmpty { return }
    if apiViewModel.mainFeed.count == 1 {
      guard let urlString = apiViewModel.mainFeed.first?.videoUrl else { return }
      currentPlayer = AVPlayer(url: URL(string: urlString)!)
      return
    }
    if index == 0 {
      guard let urlString = apiViewModel.mainFeed.first?.videoUrl else { return }
      currentPlayer = AVPlayer(url: URL(string: urlString)!)
      guard let urlStringNext = apiViewModel.mainFeed[1].videoUrl else { return }
      nextPlayer = AVPlayer(url: URL(string: urlStringNext)!)
    } else if index == apiViewModel.myFeed.count - 1 {
      guard let urlString = apiViewModel.mainFeed.last?.videoUrl else { return }
      currentPlayer = AVPlayer(url: URL(string: urlString)!)
      guard let urlStringPrev = apiViewModel.mainFeed[index - 1].videoUrl else { return }
      prevPlayer = AVPlayer(url: URL(string: urlStringPrev)!)
    } else {
      guard let urlString = apiViewModel.mainFeed[index].videoUrl else { return }
      currentPlayer = AVPlayer(url: URL(string: urlString)!)
      guard let urlStringPrev = apiViewModel.mainFeed[index - 1].videoUrl else { return }
      prevPlayer = AVPlayer(url: URL(string: urlStringPrev)!)
      guard let urlStringNext = apiViewModel.mainFeed[index + 1].videoUrl else { return }
      nextPlayer = AVPlayer(url: URL(string: urlStringNext)!)
    }
  }

  func removePlayer(completion: @escaping () -> Void) {
    stopPlayer()
    if apiViewModel.mainFeed.count == 1 {
      apiViewModel.mainFeed.removeAll()
      prevPlayer = nil
      currentPlayer = nil
      nextPlayer = nil
      return
    }
    if apiViewModel.mainFeed.count == 2, currentVideoIndex == 0 {
      currentPlayer = nil
      currentPlayer = nextPlayer
      apiViewModel.mainFeed.remove(at: currentVideoIndex)
      nextPlayer = AVPlayer(url: URL(string: apiViewModel.mainFeed[currentVideoIndex].videoUrl ?? "")!)
      currentPlayer?.seek(to: .zero)
      if BlockList.shared.userIds.contains(apiViewModel.mainFeed[currentVideoIndex].userId ?? 0) {
        return
      }
      currentPlayer?.play()
      return
    }
    if currentVideoIndex == apiViewModel.mainFeed.count - 1 {
      currentPlayer = nil
      currentPlayer = prevPlayer
      apiViewModel.mainFeed.removeLast()
      currentVideoIndex -= 1
      if currentVideoIndex == 0 {
        prevPlayer = nil
      } else {
        prevPlayer = AVPlayer(url: URL(string: apiViewModel.mainFeed[currentVideoIndex - 1].videoUrl ?? "")!)
      }
      currentPlayer?.seek(to: .zero)
      if BlockList.shared.userIds.contains(apiViewModel.mainFeed[currentVideoIndex].userId ?? 0) {
        return
      }
      currentPlayer?.play()
      completion()
    } else {
      currentPlayer = nil
      currentPlayer = nextPlayer
      apiViewModel.mainFeed.remove(at: currentVideoIndex)
      nextPlayer = AVPlayer(url: URL(string: apiViewModel.mainFeed[currentVideoIndex + 1].videoUrl ?? "")!)
      currentPlayer?.seek(to: .zero)
      if BlockList.shared.userIds.contains(apiViewModel.mainFeed[currentVideoIndex].userId ?? 0) {
        return
      }
      currentPlayer?.play()
    }
  }
}
