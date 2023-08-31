//
//  Extension+UIScreen.swift
//  Whistle
//
//  Created by 박상원 on 2023/08/23.
//

import Foundation
import SwiftUI

extension UIScreen {
  static let width = UIScreen.main.bounds.size.width
  static let height = UIScreen.main.bounds.size.height
  static let size = UIScreen.main.bounds.size

  /// 아이폰 14 Pro로 디자인된 요소들을 다른 요소에서도 맞도록 변경하는 함수입니다.
  /// - Parameter width: Figma 기준 width
  /// - Returns: 실기기 기준 width
  static func getWidth(_ width: CGFloat) -> CGFloat {
    self.width / 393 * width
  }

  /// 아이폰 14 Pro로 디자인된 너비를 다른 기기에도 맞도록 변경하는 함수입니다.
  /// - Parameter height: Figma 기준 height
  /// - Returns: 실기기 기준 height
  static func getHeight(_ height: CGFloat) -> CGFloat {
    self.height / 852 * height
  }
}
