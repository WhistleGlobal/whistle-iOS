//
//  AppleSDGothic.swift
//  Whistle
//
//  Created by ChoiYujin on 8/29/23.
//

import SwiftUI

// MARK: - AppleSDGothic

struct AppleSDGothic: ViewModifier {
  @State var fontweight: Font.Weight = .regular
  @State var fontsize: CGFloat = 16

  func body(content: Content) -> some View {
    switch fontweight {
    case .regular:
      content
        .font(.custom("AppleSDGothicNeo-Regular", size: fontsize))
    case .semibold:
      content
        .font(.custom("AppleSDGothicNeo-SemiBold", size: fontsize))
    default:
      content.font(.custom("AppleSDGothicNeo-Regular", size: fontsize))
    }
  }
}
