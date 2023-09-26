//
//  TextData.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/17.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

// MARK: - TextData

final class TextData: Codable {

  var frame: CGRect = .zero
  var finalFrame: CGRect = .zero

  var text = ""
  var colorIdx = 0
  var isTextSelected = true
  var imageData = Data()

  var point: CGPoint = .zero
  var scale: CGFloat = 1.0
  var rotation: CGFloat = 0.0

  var pointBeforePan: CGPoint = .zero
}

extension TextData {

  var image: UIImage {
    UIImage(data: imageData, scale: UIScreen.main.scale) ?? UIImage()
  }
}

// MARK: Equatable

extension TextData: Equatable {

  static func == (lhs: TextData, rhs: TextData) -> Bool {
    lhs.frame == rhs.frame
      && lhs.text == rhs.text
      && lhs.colorIdx == rhs.colorIdx
      && lhs.point == rhs.point
      && lhs.scale == rhs.scale
      && lhs.rotation == rhs.rotation
  }
}
