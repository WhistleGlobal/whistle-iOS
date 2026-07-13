import AVFoundation

// MARK: - BaseFeedPlayersViewModel

class BaseFeedPlayersViewModel: ObservableObject {
  @Published var prevPlayer: AVPlayer?
  @Published var currentPlayer: AVPlayer?
  @Published var nextPlayer: AVPlayer?
  @Published var apiViewModel = APIViewModel.shared
  @Published var currentVideoIndex = 0

  var feedCount: Int { 0 }

  func videoURL(at _: Int) -> String? {
    nil
  }

  func shouldAutoPlayCurrent() -> Bool {
    true
  }

  func removeAllContents() { }

  func removeContent(at _: Int) { }

  func removeLastContent() { }

  func goPlayerNext() {
    let lastIndex = feedCount - 1
    guard lastIndex >= 0 else { return }

    let index = min(max(0, currentVideoIndex), lastIndex)
    stopPlayer()
    prevPlayer = currentPlayer
    currentPlayer = nextPlayer
    nextPlayer = nil
    if index < lastIndex {
      nextPlayer = makePlayer(at: index + 1)
    }
    currentPlayer?.seek(to: .zero)
    playCurrentIfAllowed()
  }

  func goPlayerPrev() {
    guard feedCount > 0 else { return }

    stopPlayer()
    nextPlayer = currentPlayer
    currentPlayer = prevPlayer
    prevPlayer = nil
    if currentVideoIndex != 0 {
      prevPlayer = makePlayer(at: currentVideoIndex - 1)
    }
    currentPlayer?.seek(to: .zero)
    playCurrentIfAllowed()
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
    guard feedCount > 0 else { return }
    currentPlayer = makePlayer(at: 0)
    if feedCount < 2 { return }
    nextPlayer = makePlayer(at: 1)
  }

  func initialPlayers(index: Int) {
    guard feedCount > 0 else { return }

    if feedCount == 1 {
      currentPlayer = makePlayer(at: 0)
      return
    }

    if index <= 0 {
      currentPlayer = makePlayer(at: 0)
      prevPlayer = nil
      nextPlayer = makePlayer(at: 1)
    } else if index >= feedCount - 1 {
      currentPlayer = makePlayer(at: feedCount - 1)
      prevPlayer = makePlayer(at: feedCount - 2)
      nextPlayer = nil
    } else {
      currentPlayer = makePlayer(at: index)
      prevPlayer = makePlayer(at: index - 1)
      nextPlayer = makePlayer(at: index + 1)
    }
  }

  func removePlayer(completion: @escaping () -> Void) {
    stopPlayer()

    let count = feedCount
    if count == 1 {
      removeAllContents()
      resetPlayer()
      return
    }

    if count == 2, currentVideoIndex == 0 {
      currentPlayer = nextPlayer
      removeContent(at: currentVideoIndex)
      nextPlayer = makePlayer(at: currentVideoIndex)
      currentPlayer?.seek(to: .zero)
      playCurrentIfAllowed()
      return
    }

    if currentVideoIndex == count - 1 {
      currentPlayer = prevPlayer
      removeLastContent()
      currentVideoIndex -= 1
      if currentVideoIndex == 0 {
        prevPlayer = nil
      } else {
        prevPlayer = makePlayer(at: currentVideoIndex - 1)
      }
      currentPlayer?.seek(to: .zero)
      playCurrentIfAllowed()
      completion()
    } else {
      currentPlayer = nextPlayer
      removeContent(at: currentVideoIndex)
      if currentVideoIndex != feedCount - 1 {
        nextPlayer = makePlayer(at: currentVideoIndex + 1)
      } else {
        nextPlayer = nil
      }
      currentPlayer?.seek(to: .zero)
      playCurrentIfAllowed()
    }
  }

  private func makePlayer(at index: Int) -> AVPlayer? {
    guard index >= 0, index < feedCount else { return nil }
    guard let urlString = videoURL(at: index), let url = URL(string: urlString) else { return nil }
    return AVPlayer(url: url)
  }

  private func playCurrentIfAllowed() {
    if shouldAutoPlayCurrent() {
      currentPlayer?.play()
    }
  }
}

// MARK: - TagSearchPlayersViewModel

final class TagSearchPlayersViewModel: BaseFeedPlayersViewModel {

  @Published var searchedContents: [MainContent] = []

  override var feedCount: Int {
    searchedContents.count
  }

  override func videoURL(at index: Int) -> String? {
    searchedContents[index].videoUrl
  }

  override func removeAllContents() {
    searchedContents.removeAll()
  }

  override func removeContent(at index: Int) {
    searchedContents.remove(at: index)
  }

  override func removeLastContent() {
    searchedContents.removeLast()
  }
}
