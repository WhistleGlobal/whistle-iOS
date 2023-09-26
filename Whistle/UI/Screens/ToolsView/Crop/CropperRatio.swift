//
//  CropperRatio.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import CoreGraphics
import Foundation

struct CropperRatio {
  let width: CGFloat
  let height: CGFloat

  init(width: CGFloat, height: CGFloat) {
    self.width = width
    self.height = height
  }

  static var r_1_1: Self {
    .init(width: 1, height: 1)
  }

  static var r_3_2: Self {
    .init(width: 3, height: 2)
  }

  static var r_4_3: Self {
    .init(width: 4, height: 3)
  }

  static var r_16_9: Self {
    .init(width: 16, height: 9)
  }

  static var r_18_6: Self {
    .init(width: 18, height: 6)
  }
}
