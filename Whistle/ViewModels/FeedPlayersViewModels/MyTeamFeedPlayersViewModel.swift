//
//  MyTeamFeedPlayersViewModel.swift
//  Whistle
//
//  Created by ChoiYujin on 11/22/23.
//

import AVFoundation

// FIXME: - MyTeam API 나오면 고쳐보기

class MyTeamFeedPlayersViewModel: BaseFeedPlayersViewModel {

  static let shared = MyTeamFeedPlayersViewModel()
  private override init() {
    super.init()
  }

  override var feedCount: Int {
    apiViewModel.myTeamFeed.count
  }

  override func videoURL(at index: Int) -> String? {
    apiViewModel.myTeamFeed[index].videoUrl
  }

  override func shouldAutoPlayCurrent() -> Bool {
    guard apiViewModel.myTeamFeed.indices.contains(currentVideoIndex) else { return true }
    return !BlockList.shared.userIds.contains(apiViewModel.myTeamFeed[currentVideoIndex].userId ?? 0)
  }

  override func initialPlayers(index: Int) {
    WhistleLogger.logger.debug("initialPlayers(index: \(index))")
    super.initialPlayers(index: index)
  }

  override func removeAllContents() {
    apiViewModel.myTeamFeed.removeAll()
  }

  override func removeContent(at index: Int) {
    apiViewModel.myTeamFeed.remove(at: index)
  }

  override func removeLastContent() {
    apiViewModel.myTeamFeed.removeLast()
  }
}
