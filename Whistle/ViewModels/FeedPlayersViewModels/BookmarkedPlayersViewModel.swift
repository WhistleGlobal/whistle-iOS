//
//  BookmarkedPlayersViewModel.swift
//  Whistle
//
//  Created by ChoiYujin on 10/30/23.
//

import AVFoundation

class BookmarkedPlayersViewModel: BaseFeedPlayersViewModel {

  static let shared = BookmarkedPlayersViewModel()
  private override init() {
    super.init()
  }

  override var feedCount: Int {
    apiViewModel.bookmark.count
  }

  override func videoURL(at index: Int) -> String? {
    apiViewModel.bookmark[index].videoUrl
  }

  override func removeAllContents() {
    apiViewModel.bookmark.removeAll()
  }

  override func removeContent(at index: Int) {
    apiViewModel.bookmark.remove(at: index)
  }

  override func removeLastContent() {
    apiViewModel.bookmark.removeLast()
  }
}
