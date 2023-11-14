//
//  ContentLayerButtonType.swift
//  Whistle
//
//  Created by 박상원 on 11/10/23.
//

import Foundation
import SwiftUI

// MARK: - ContentLayerButtonType

enum ContentLayerButtonType {
  case whistle(String), bookmark, share, more

  var buttonLabel: LocalizedStringKey {
    switch self {
    case .whistle(let count):
      "\(count)"
    case .bookmark:
      CommonWords().bookmark
    case .share:
      CommonWords().share
    case .more:
      CommonWords().more
    }
  }

  var defaultSymbol: String {
    switch self {
    case .whistle:
      "heart"
    case .bookmark:
      "bookmark"
    case .share:
      "square.and.arrow.up"
    case .more:
      "ellipsis"
    }
  }

  var filledSymbol: String {
    switch self {
    case .whistle:
      "heart.fill"
    case .bookmark:
      "bookmark.fill"
    case .share:
      "square.and.arrow.up"
    case .more:
      "ellipsis"
    }
  }
}
