//
//  TagSeacrhPlayersViewModel.swift
//  Whistle
//
//  Created by ChoiYujin on 11/15/23.
//

import AVFoundation

class TagSearchPlayersViewModel: BaseFeedPlayersViewModel {

//  static let shared = TagSearchPlayersViewModel()
//  private init() { }

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
