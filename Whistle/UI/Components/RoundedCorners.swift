//
//  RoundedCorners.swift
//  Whistle
//
//  Created by ChoiYujin on 8/30/23.
//

import SwiftUI

struct RoundedCorners: Shape {

  var radius: CGFloat = .infinity
  var corners: UIRectCorner = .allCorners

  func path(in rect: CGRect) -> Path {
    let path = UIBezierPath(
      roundedRect: rect,
      byRoundingCorners: corners,
      cornerRadii: CGSize(width: radius, height: radius))
    return Path(path.cgPath)
  }
}
