final class GuestFeedPlayersViewModel: BaseFeedPlayersViewModel {

  static let shared = GuestFeedPlayersViewModel()
  private override init() {
    super.init()
  }

  override var feedCount: Int {
    apiViewModel.guestFeed.count
  }

  override func videoURL(at index: Int) -> String? {
    apiViewModel.guestFeed[index].videoUrl
  }

  override func shouldAutoPlayCurrent() -> Bool {
    guard apiViewModel.guestFeed.indices.contains(currentVideoIndex) else { return true }
    return !BlockList.shared.userIds.contains(apiViewModel.guestFeed[currentVideoIndex].userId ?? 0)
  }

  override func removeAllContents() {
    apiViewModel.guestFeed.removeAll()
  }

  override func removeContent(at index: Int) {
    apiViewModel.guestFeed.remove(at: index)
  }

  override func removeLastContent() {
    apiViewModel.guestFeed.removeLast()
  }
}
