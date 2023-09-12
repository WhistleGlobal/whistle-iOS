//
//  OffsetKey.swift
//  Whistle
//
//  Created by ChoiYujin on 9/12/23.
//

import Foundation
import SwiftUI

// MARK: - Scroll Sticky header에 쓸 기능
struct OffsetKey: PreferenceKey {

  static var defaultValue: CGFloat = 0
  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value = nextValue()
  }
}
