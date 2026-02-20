final class MyFeedPlayersViewModel: BaseFeedPlayersViewModel {

  static let shared = MyFeedPlayersViewModel()
  private override init() {
    super.init()
  }

  override var feedCount: Int {
    apiViewModel.myFeed.count
  }

  override func videoURL(at index: Int) -> String? {
    apiViewModel.myFeed[index].videoUrl
  }

  override func initialPlayers(index: Int) {
    WhistleLogger.logger.debug("initialPlayers(index: \(index))")
    super.initialPlayers(index: index)
  }

  override func removeAllContents() {
    apiViewModel.myFeed.removeAll()
  }

  override func removeContent(at index: Int) {
    apiViewModel.myFeed.remove(at: index)
  }

  override func removeLastContent() {
    apiViewModel.myFeed.removeLast()
  }
}
