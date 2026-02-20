//
//  FeedPlayersViewModel.swift
//  Whistle
//
//  Created by ChoiYujin on 10/26/23.
//

import AVFoundation

class MainFeedPlayersViewModel: BaseFeedPlayersViewModel {

  static let shared = MainFeedPlayersViewModel()
  private override init() {
    super.init()
  }

  override var feedCount: Int {
    apiViewModel.mainFeed.count
  }

  override func videoURL(at index: Int) -> String? {
    apiViewModel.mainFeed[index].videoUrl
  }

  override func shouldAutoPlayCurrent() -> Bool {
    guard apiViewModel.mainFeed.indices.contains(currentVideoIndex) else { return true }
    return !BlockList.shared.userIds.contains(apiViewModel.mainFeed[currentVideoIndex].userId ?? 0)
  }

  override func initialPlayers(index: Int) {
    WhistleLogger.logger.debug("initialPlayers(index: \(index))")
    super.initialPlayers(index: index)
  }

  override func removeAllContents() {
    apiViewModel.mainFeed.removeAll()
  }

  override func removeContent(at index: Int) {
    apiViewModel.mainFeed.remove(at: index)
  }

  override func removeLastContent() {
    apiViewModel.mainFeed.removeLast()
  }
}
