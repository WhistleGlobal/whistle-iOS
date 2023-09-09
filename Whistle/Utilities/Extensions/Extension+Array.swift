//
//  Extension+Array.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/05.
//

import Foundation

// MARK: - AudioVisualizer 관련 코드
extension Array {
  func chunked(into size: Int) -> [[Element]] {
    stride(from: 0, to: count, by: size).map {
      Array(self[$0 ..< Swift.min($0 + size, count)])
    }
  }
}
