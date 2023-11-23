//
//  GuestPlayersViewModel.swift
//  Whistle
//
//  Created by ChoiYujin on 11/1/23.
//

import AVFoundation

class GuestFeedPlayersViewModel: ObservableObject {

  static let shared = GuestFeedPlayersViewModel()
  private init() { }

  @Published var prevPlayer: AVPlayer?
  @Published var currentPlayer: AVPlayer?
  @Published var nextPlayer: AVPlayer?
  @Published var apiViewModel = APIViewModel.shared
  @Published var currentVideoIndex = 0

  func goPlayerNext() {
    let index = min(max(0, currentVideoIndex), apiViewModel.guestFeed.count - 1)
    if index == apiViewModel.guestFeed.count - 1 {
      stopPlayer()
      prevPlayer = nil
      prevPlayer = currentPlayer
      currentPlayer = nextPlayer
      nextPlayer = nil
      currentPlayer?.seek(to: .zero)
      if BlockList.shared.userIds.contains(apiViewModel.guestFeed[currentVideoIndex].userId ?? 0) {
        return
      }
      currentPlayer?.play()
    } else {
      stopPlayer()
      prevPlayer = nil
      prevPlayer = currentPlayer
      currentPlayer = nextPlayer
      nextPlayer = nil
      nextPlayer = AVPlayer(url: URL(string: apiViewModel.guestFeed[index + 1].videoUrl ?? "")!)
      currentPlayer?.seek(to: .zero)
      if BlockList.shared.userIds.contains(apiViewModel.guestFeed[currentVideoIndex].userId ?? 0) {
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
      if BlockList.shared.userIds.contains(apiViewModel.guestFeed[currentVideoIndex].userId ?? 0) {
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
      prevPlayer = AVPlayer(url: URL(string: apiViewModel.guestFeed[currentVideoIndex - 1].videoUrl ?? "")!)
    }
    currentPlayer?.seek(to: .zero)
    if BlockList.shared.userIds.contains(apiViewModel.guestFeed[currentVideoIndex].userId ?? 0) {
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
    if apiViewModel.guestFeed.isEmpty { return }
    guard let urlString = apiViewModel.guestFeed.first?.videoUrl else { return }
    currentPlayer = AVPlayer(url: URL(string: urlString)!)
    if apiViewModel.guestFeed.count < 2 { return }
    guard let urlStringNext = apiViewModel.guestFeed[1].videoUrl else { return }
    nextPlayer = AVPlayer(url: URL(string: urlStringNext)!)
  }

  func removePlayer(completion: @escaping () -> Void) {
    stopPlayer()
    if apiViewModel.guestFeed.count == 1 {
      apiViewModel.guestFeed.removeAll()
      prevPlayer = nil
      currentPlayer = nil
      nextPlayer = nil
      return
    }
    if apiViewModel.guestFeed.count == 2, currentVideoIndex == 0 {
      currentPlayer = nil
      currentPlayer = nextPlayer
      apiViewModel.guestFeed.remove(at: currentVideoIndex)
      nextPlayer = AVPlayer(url: URL(string: apiViewModel.guestFeed[currentVideoIndex].videoUrl ?? "")!)
      currentPlayer?.seek(to: .zero)
      if BlockList.shared.userIds.contains(apiViewModel.guestFeed[currentVideoIndex].userId ?? 0) {
        return
      }
      currentPlayer?.play()
      return
    }
    if currentVideoIndex == apiViewModel.guestFeed.count - 1 {
      currentPlayer = nil
      currentPlayer = prevPlayer
      apiViewModel.guestFeed.removeLast()
      currentVideoIndex -= 1
      if currentVideoIndex == 0 {
        prevPlayer = nil
      } else {
        prevPlayer = AVPlayer(url: URL(string: apiViewModel.guestFeed[currentVideoIndex - 1].videoUrl ?? "")!)
      }
      currentPlayer?.seek(to: .zero)
      if BlockList.shared.userIds.contains(apiViewModel.guestFeed[currentVideoIndex].userId ?? 0) {
        return
      }
      currentPlayer?.play()
      completion()
    } else {
      currentPlayer = nil
      currentPlayer = nextPlayer
      apiViewModel.guestFeed.remove(at: currentVideoIndex)
      nextPlayer = AVPlayer(url: URL(string: apiViewModel.guestFeed[currentVideoIndex + 1].videoUrl ?? "")!)
      currentPlayer?.seek(to: .zero)
      if BlockList.shared.userIds.contains(apiViewModel.guestFeed[currentVideoIndex].userId ?? 0) {
        return
      }
      currentPlayer?.play()
    }
  }
}
