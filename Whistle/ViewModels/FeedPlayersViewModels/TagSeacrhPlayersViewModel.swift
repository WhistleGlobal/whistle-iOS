//
//  TagSeacrhPlayersViewModel.swift
//  Whistle
//
//  Created by ChoiYujin on 11/15/23.
//

import AVFoundation

class TagSearchPlayersViewModel: ObservableObject {

//  static let shared = TagSearchPlayersViewModel()
//  private init() { }

  @Published var prevPlayer: AVPlayer?
  @Published var currentPlayer: AVPlayer?
  @Published var nextPlayer: AVPlayer?
  @Published var apiViewModel = APIViewModel.shared
  @Published var searchedContents: [MainContent] = []
  @Published var currentVideoIndex = 0

  func goPlayerNext() {
    let index = min(max(0, currentVideoIndex), searchedContents.count - 1)
    if index == searchedContents.count - 1 {
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
      nextPlayer = AVPlayer(url: URL(string: searchedContents[index + 1].videoUrl ?? "")!)
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
      prevPlayer = AVPlayer(url: URL(string: searchedContents[currentVideoIndex - 1].videoUrl ?? "")!)
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
    if searchedContents.isEmpty { return }
    guard let urlString = searchedContents.first?.videoUrl else { return }
    currentPlayer = AVPlayer(url: URL(string: urlString)!)
    if searchedContents.count < 2 { return }
    let urlStringNext = searchedContents[1].videoUrl
    nextPlayer = AVPlayer(url: URL(string: urlStringNext ?? "")!)
  }

  func initialPlayers(index: Int) {
    if searchedContents.isEmpty { return }
    if searchedContents.count == 1 {
      guard let urlString = searchedContents.first?.videoUrl else { return }
      currentPlayer = AVPlayer(url: URL(string: urlString)!)
      return
    }
    if index == 0 {
      guard let urlString = searchedContents.first?.videoUrl else { return }
      currentPlayer = AVPlayer(url: URL(string: urlString)!)
      let urlStringNext = searchedContents[1].videoUrl
      nextPlayer = AVPlayer(url: URL(string: urlStringNext ?? "")!)
    } else if index == searchedContents.count - 1 {
      guard let urlString = searchedContents.last?.videoUrl else { return }
      currentPlayer = AVPlayer(url: URL(string: urlString)!)
      let urlStringPrev = searchedContents[index - 1].videoUrl
      prevPlayer = AVPlayer(url: URL(string: urlStringPrev ?? "")!)
    } else {
      let urlString = searchedContents[index].videoUrl
      currentPlayer = AVPlayer(url: URL(string: urlString ?? "")!)
      let urlStringPrev = searchedContents[index - 1].videoUrl
      prevPlayer = AVPlayer(url: URL(string: urlStringPrev ?? "")!)
      let urlStringNext = searchedContents[index + 1].videoUrl
      nextPlayer = AVPlayer(url: URL(string: urlStringNext ?? "")!)
    }
  }

  func removePlayer(completion: @escaping () -> Void) {
    stopPlayer()
    if searchedContents.count == 1 {
      searchedContents.removeAll()
      prevPlayer = nil
      currentPlayer = nil
      nextPlayer = nil
      return
    }
    if searchedContents.count == 2, currentVideoIndex == 0 {
      currentPlayer = nil
      currentPlayer = nextPlayer
      searchedContents.remove(at: currentVideoIndex)
      nextPlayer = AVPlayer(url: URL(string: searchedContents[currentVideoIndex].videoUrl ?? "")!)
      currentPlayer?.seek(to: .zero)
      currentPlayer?.play()
      return
    }
    if currentVideoIndex == searchedContents.count - 1 {
      currentPlayer = nil
      currentPlayer = prevPlayer
      searchedContents.removeLast()
      currentVideoIndex -= 1
      if currentVideoIndex == 0 {
        prevPlayer = nil
      } else {
        prevPlayer = AVPlayer(url: URL(string: searchedContents[currentVideoIndex - 1].videoUrl ?? "")!)
      }
      currentPlayer?.seek(to: .zero)
      currentPlayer?.play()
      completion()
    } else {
      currentPlayer = nil
      currentPlayer = nextPlayer
      nextPlayer = AVPlayer(url: URL(string: searchedContents[currentVideoIndex + 1].videoUrl ?? "")!)
      searchedContents.remove(at: currentVideoIndex)
      currentPlayer?.seek(to: .zero)
      currentPlayer?.play()
    }
  }
}
