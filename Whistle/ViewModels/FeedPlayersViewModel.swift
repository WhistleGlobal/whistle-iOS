//
//  FeedPlayersViewModel.swift
//  Whistle
//
//  Created by ChoiYujin on 10/26/23.
//

import AVFoundation

class FeedPlayersViewModel: ObservableObject {

  static let shared = FeedPlayersViewModel()
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
      currentPlayer?.play()
    } else {
      stopPlayer()
      prevPlayer = nil
      prevPlayer = currentPlayer
      currentPlayer = nextPlayer
      nextPlayer = nil
      nextPlayer = AVPlayer(url: URL(string: apiViewModel.mainFeed[index + 1].videoUrl ?? "")!)
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
    print("goPlayerPrev currentVideoIndex: \(currentVideoIndex)")
    if currentVideoIndex != 0 {
      prevPlayer = AVPlayer(url: URL(string: apiViewModel.mainFeed[currentVideoIndex - 1].videoUrl ?? "")!)
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

  func initialPlayers() {
    if apiViewModel.mainFeed.isEmpty { return }
    guard let urlString = apiViewModel.mainFeed.first?.videoUrl else { return }
    if apiViewModel.mainFeed.count < 2 { return }
    guard let urlStringNext = apiViewModel.mainFeed[1].videoUrl else { return }
    currentPlayer = AVPlayer(url: URL(string: urlString)!)
    nextPlayer = AVPlayer(url: URL(string: urlStringNext)!)
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
    if currentVideoIndex == apiViewModel.mainFeed.count - 1 {
      currentPlayer = nil
      currentPlayer = prevPlayer
      apiViewModel.mainFeed.removeLast()
      currentVideoIndex -= 1
      print("removePlayer apiViewModel.mainFeed.count: \(apiViewModel.mainFeed.count)")
      print("removePlayer currentVideoIndex: \(currentVideoIndex)")
      if currentVideoIndex == 0 {
        prevPlayer = nil
      } else {
        prevPlayer = AVPlayer(url: URL(string: apiViewModel.mainFeed[currentVideoIndex - 1].videoUrl ?? "")!)
      }
      currentPlayer?.seek(to: .zero)
      currentPlayer?.play()
      completion()
    } else {
      currentPlayer = nil
      currentPlayer = nextPlayer
      apiViewModel.mainFeed.remove(at: currentVideoIndex)
      nextPlayer = AVPlayer(url: URL(string: apiViewModel.mainFeed[currentVideoIndex + 1].videoUrl ?? "")!)
      currentPlayer?.seek(to: .zero)
      currentPlayer?.play()
    }
  }
}
