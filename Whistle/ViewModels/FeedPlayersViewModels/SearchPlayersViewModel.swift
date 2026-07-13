// MARK: - SearchPlayersViewModel

final class SearchPlayersViewModel: BaseFeedPlayersViewModel {

  static let shared = SearchPlayersViewModel()
  private override init() {
    super.init()
  }

  override var feedCount: Int {
    apiViewModel.searchedContent.count
  }

  override func videoURL(at index: Int) -> String? {
    apiViewModel.searchedContent[index].videoUrl
  }

  override func removeAllContents() {
    apiViewModel.searchedContent.removeAll()
  }

  override func removeContent(at index: Int) {
    apiViewModel.searchedContent.remove(at: index)
  }

  override func removeLastContent() {
    apiViewModel.searchedContent.removeLast()
  }
}
