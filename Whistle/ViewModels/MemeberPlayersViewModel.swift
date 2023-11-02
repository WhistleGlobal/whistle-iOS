//
//  MemeberPlayersViewModel.swift
//  Whistle
//
//  Created by ChoiYujin on 10/31/23.
//

import AVFoundation

class MemeberPlayersViewModel: ObservableObject {

  static let shared = MemeberPlayersViewModel()
  private init() { }

  @Published var prevPlayer: AVPlayer?
  @Published var currentPlayer: AVPlayer?
  @Published var nextPlayer: AVPlayer?
  @Published var apiViewModel = APIViewModel.shared
  @Published var currentVideoIndex = 0

  func goPlayerNext() {
    let index = min(max(0, currentVideoIndex), apiViewModel.memberFeed.count - 1)
    if index == apiViewModel.memberFeed.count - 1 {
      stopPlayer()
      prevPlayer = nil
      prevPlayer = currentPlayer
      currentPlayer = nextPlayer
      nextPlayer = nil
      currentPlayer?.seek(to: .zero)
      if apiViewModel.memberFeed[currentVideoIndex].isHated {
        return
      }
      currentPlayer?.play()
    } else {
      stopPlayer()
      prevPlayer = nil
      prevPlayer = currentPlayer
      currentPlayer = nextPlayer
      nextPlayer = nil
      nextPlayer = AVPlayer(url: URL(string: apiViewModel.memberFeed[index + 1].videoUrl ?? "")!)
      currentPlayer?.seek(to: .zero)
      if apiViewModel.memberFeed[currentVideoIndex].isHated {
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
      if apiViewModel.memberFeed[currentVideoIndex].isHated {
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
      prevPlayer = AVPlayer(url: URL(string: apiViewModel.memberFeed[currentVideoIndex - 1].videoUrl ?? "")!)
    }
    currentPlayer?.seek(to: .zero)
    if apiViewModel.memberFeed[currentVideoIndex].isHated {
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
    if apiViewModel.memberFeed.isEmpty { return }
    guard let urlString = apiViewModel.memberFeed.first?.videoUrl else { return }
    currentPlayer = AVPlayer(url: URL(string: urlString)!)
    if apiViewModel.memberFeed.count < 2 { return }
    let urlStringNext = apiViewModel.memberFeed[1].videoUrl
    nextPlayer = AVPlayer(url: URL(string: urlStringNext ?? "")!)
  }

  func initialPlayers(index: Int) {
    if apiViewModel.memberFeed.isEmpty { return }
    if apiViewModel.memberFeed.count == 1 {
      guard let urlString = apiViewModel.memberFeed.first?.videoUrl else { return }
      currentPlayer = AVPlayer(url: URL(string: urlString)!)
      return
    }
    if index == 0 {
      guard let urlString = apiViewModel.memberFeed.first?.videoUrl else { return }
      currentPlayer = AVPlayer(url: URL(string: urlString)!)
      let urlStringNext = apiViewModel.memberFeed[1].videoUrl
      nextPlayer = AVPlayer(url: URL(string: urlStringNext ?? "")!)
    } else if index == apiViewModel.memberFeed.count - 1 {
      guard let urlString = apiViewModel.memberFeed.last?.videoUrl else { return }
      currentPlayer = AVPlayer(url: URL(string: urlString)!)
      let urlStringPrev = apiViewModel.memberFeed[index - 1].videoUrl
      prevPlayer = AVPlayer(url: URL(string: urlStringPrev ?? "")!)
    } else {
      let urlString = apiViewModel.memberFeed[index].videoUrl
      currentPlayer = AVPlayer(url: URL(string: urlString ?? "")!)
      let urlStringPrev = apiViewModel.memberFeed[index - 1].videoUrl
      prevPlayer = AVPlayer(url: URL(string: urlStringPrev ?? "")!)
      let urlStringNext = apiViewModel.memberFeed[index + 1].videoUrl
      nextPlayer = AVPlayer(url: URL(string: urlStringNext ?? "")!)
    }
  }

  func removePlayer(completion: @escaping () -> Void) {
    stopPlayer()
    if apiViewModel.memberFeed.count == 1 {
      apiViewModel.memberFeed.removeAll()
      prevPlayer = nil
      currentPlayer = nil
      nextPlayer = nil
      return
    }
    if apiViewModel.memberFeed.count == 2, currentVideoIndex == 0 {
      currentPlayer = nil
      currentPlayer = nextPlayer
      apiViewModel.memberFeed.remove(at: currentVideoIndex)
      nextPlayer = AVPlayer(url: URL(string: apiViewModel.memberFeed[currentVideoIndex].videoUrl ?? "")!)
      currentPlayer?.seek(to: .zero)
      if apiViewModel.memberFeed[currentVideoIndex].isHated {
        return
      }
      currentPlayer?.play()
      return
    }
    if currentVideoIndex == apiViewModel.memberFeed.count - 1 {
      currentPlayer = nil
      currentPlayer = prevPlayer
      apiViewModel.memberFeed.removeLast()
      currentVideoIndex -= 1
      if currentVideoIndex == 0 {
        prevPlayer = nil
      } else {
        prevPlayer = AVPlayer(url: URL(string: apiViewModel.memberFeed[currentVideoIndex - 1].videoUrl ?? "")!)
      }
      currentPlayer?.seek(to: .zero)
      if apiViewModel.memberFeed[currentVideoIndex].isHated {
        return
      }
      currentPlayer?.play()
      completion()
    } else {
      currentPlayer = nil
      currentPlayer = nextPlayer
        nextPlayer = AVPlayer(url: URL(string: apiViewModel.memberFeed[currentVideoIndex + 1].videoUrl ?? "")!)
      apiViewModel.memberFeed.remove(at: currentVideoIndex)
      currentPlayer?.seek(to: .zero)
      if apiViewModel.memberFeed[currentVideoIndex].isHated {
        return
      }
      currentPlayer?.play()
    }
  }
}
