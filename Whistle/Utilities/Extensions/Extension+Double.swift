//
//  Extension_Double.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import Foundation

extension Double {
  func formatterTimeString() -> String {
    let minutes = Int(self / 60)
    let seconds = Int(truncatingRemainder(dividingBy: 60))
    return "\(minutes):\(String(format: "%02d", seconds))"
  }
}
