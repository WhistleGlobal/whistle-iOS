//
//  MyFeedPlayersViewModel.swift
//  Whistle
//
//  Created by ChoiYujin on 10/30/23.
//

import AVFoundation

class MyFeedPlayersViewModel: ObservableObject {

  static let shared = MyFeedPlayersViewModel()
  private init() { }

  @Published var prevPlayer: AVPlayer?
  @Published var currentPlayer: AVPlayer?
  @Published var nextPlayer: AVPlayer?
  @Published var apiViewModel = APIViewModel.shared
  @Published var currentVideoIndex = 0

  func goPlayerNext() {
    let index = min(max(0, currentVideoIndex), apiViewModel.myFeed.count - 1)
    if index == apiViewModel.myFeed.count - 1 {
      stopPlayer()
      prevPlayer = nil
      prevPlayer = currentPlayer
      currentPlayer = nextPlayer
      nextPlayer = nil
      currentPlayer?.seek(to: .zero)
      currentPlayer?.play()
    } else {
      stopPlayer()
      prevPlayer = nil
      prevPlayer = currentPlayer
      currentPlayer = nextPlayer
      nextPlayer = nil
      nextPlayer = AVPlayer(url: URL(string: apiViewModel.myFeed[index + 1].videoUrl ?? "")!)
      currentPlayer?.seek(to: .zero)
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
      prevPlayer = AVPlayer(url: URL(string: apiViewModel.myFeed[currentVideoIndex - 1].videoUrl ?? "")!)
    }
    currentPlayer?.seek(to: .zero)
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
    if apiViewModel.myFeed.isEmpty { return }
    guard let urlString = apiViewModel.myFeed.first?.videoUrl else { return }
    currentPlayer = AVPlayer(url: URL(string: urlString)!)
    if apiViewModel.myFeed.count < 2 { return }
    guard let urlStringNext = apiViewModel.myFeed[1].videoUrl else { return }
    nextPlayer = AVPlayer(url: URL(string: urlStringNext)!)
  }

  func initialPlayers(index: Int) {
    WhistleLogger.logger.debug("initialPlayers(index: \(index))")
    if apiViewModel.myFeed.isEmpty { return }
    if apiViewModel.myFeed.count == 1 {
      guard let urlString = apiViewModel.myFeed.first?.videoUrl else { return }
      currentPlayer = AVPlayer(url: URL(string: urlString)!)
      return
    }
    if index == 0 {
      guard let urlString = apiViewModel.myFeed.first?.videoUrl else { return }
      currentPlayer = AVPlayer(url: URL(string: urlString)!)
      guard let urlStringNext = apiViewModel.myFeed[1].videoUrl else { return }
      nextPlayer = AVPlayer(url: URL(string: urlStringNext)!)
    } else if index == apiViewModel.myFeed.count - 1 {
      guard let urlString = apiViewModel.myFeed.last?.videoUrl else { return }
      currentPlayer = AVPlayer(url: URL(string: urlString)!)
      guard let urlStringPrev = apiViewModel.myFeed[index - 1].videoUrl else { return }
      prevPlayer = AVPlayer(url: URL(string: urlStringPrev)!)
    } else {
      guard let urlString = apiViewModel.myFeed[index].videoUrl else { return }
      currentPlayer = AVPlayer(url: URL(string: urlString)!)
      guard let urlStringPrev = apiViewModel.myFeed[index - 1].videoUrl else { return }
      prevPlayer = AVPlayer(url: URL(string: urlStringPrev)!)
      guard let urlStringNext = apiViewModel.myFeed[index + 1].videoUrl else { return }
      nextPlayer = AVPlayer(url: URL(string: urlStringNext)!)
    }
  }

  func removePlayer(completion: @escaping () -> Void) {
    stopPlayer()
    if apiViewModel.myFeed.count == 1 {
      apiViewModel.myFeed.removeAll()
      prevPlayer = nil
      currentPlayer = nil
      nextPlayer = nil
      return
    }
    if apiViewModel.myFeed.count == 2, currentVideoIndex == 0 {
      currentPlayer = nil
      currentPlayer = nextPlayer
      apiViewModel.myFeed.remove(at: currentVideoIndex)
      nextPlayer = AVPlayer(url: URL(string: apiViewModel.myFeed[currentVideoIndex].videoUrl ?? "")!)
      currentPlayer?.seek(to: .zero)
      currentPlayer?.play()
      return
    }
    if currentVideoIndex == apiViewModel.myFeed.count - 1 {
      currentPlayer = nil
      currentPlayer = prevPlayer
      apiViewModel.myFeed.removeLast()
      currentVideoIndex -= 1
      if currentVideoIndex == 0 {
        prevPlayer = nil
      } else {
        prevPlayer = AVPlayer(url: URL(string: apiViewModel.myFeed[currentVideoIndex - 1].videoUrl ?? "")!)
      }
      currentPlayer?.seek(to: .zero)
      currentPlayer?.play()
      completion()
    } else {
      currentPlayer = nil
      currentPlayer = nextPlayer
      nextPlayer = AVPlayer(url: URL(string: apiViewModel.myFeed[currentVideoIndex + 1].videoUrl ?? "")!)
      apiViewModel.myFeed.remove(at: currentVideoIndex)
      currentPlayer?.seek(to: .zero)
      currentPlayer?.play()
    }
  }
}
