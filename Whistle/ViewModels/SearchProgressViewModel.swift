//
//  SearchProgressViewModel.swift
//  Whistle
//
//  Created by 박상원 on 11/23/23.
//

import Combine
import Foundation
import SwiftUI

// MARK: - SearchState

enum SearchState {
  case notStarted, searching, found, notFound
}

// MARK: - SearchProgressViewModel

class SearchProgressViewModel {
  static let shared = SearchProgressViewModel()

  let searchUserSubject = CurrentValueSubject<SearchState, Never>(.notStarted)
  let searchTagSubject = CurrentValueSubject<SearchState, Never>(.notStarted)
  let searchContentSubject = CurrentValueSubject<SearchState, Never>(.notStarted)
  let searchTagContentSubject = CurrentValueSubject<SearchState, Never>(.notStarted)

  var searchingUser: SearchState {
    get { searchUserSubject.value }
    set { searchUserSubject.send(newValue) }
  }

  var searchingTag: SearchState {
    get { searchTagSubject.value }
    set { searchTagSubject.send(newValue) }
  }

  var searchingContent: SearchState {
    get { searchContentSubject.value }
    set { searchContentSubject.send(newValue) }
  }

  var searchingTagContent: SearchState {
    get { searchTagContentSubject.value }
    set { searchTagContentSubject.send(newValue) }
  }

  private init() { }

  func changeSearchUserState(to: SearchState) {
    searchingUser = to
  }

  func changeSearchTagState(to: SearchState) {
    searchingTag = to
  }

  func changeSearchContentState(to: SearchState) {
    searchingContent = to
  }

  func changeSearchTagContentState(to: SearchState) {
    searchingTagContent = to
  }

  func reset() {
    searchingTag = .notStarted
    searchingUser = .notStarted
    searchingContent = .notStarted
    searchingTagContent = .notStarted
  }
}
