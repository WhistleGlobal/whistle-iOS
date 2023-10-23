//
//  Extension+Double.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import Foundation

extension Double {
  func formatterTimeString() -> String {
    let totalSeconds = Int(self) // 초를 정수로 변환
    let minutes = totalSeconds / 60
    let seconds = totalSeconds % 60
    return String(format: "%02d:%02d", minutes, seconds)
  }
}
