//
//  FontSystem.swift
//  Whistle
//
//  Created by ChoiYujin on 8/31/23.
//

import SwiftUI

struct FontSystem: ViewModifier {
  enum FontDesignSystem {
    case largeTitle
    case largeTitle_SemiBold
    case largeTitle_Expanded
    case title1
    case title1_SemiBold
    case title1_Expanded
    case title2
    case title2_SemiBold
    case title2_Expanded
    case subtitle1
    case subtitle2
    case subtitle3
    case body1
    case body2
    case caption_Regular
    case caption_SemiBold
    case caption2_Regular

  }

  @State var fontDesignSystem: FontDesignSystem

  func body(content: Content) -> some View {
    switch fontDesignSystem {
    case .largeTitle:
      content
        .font(.system(size: 32))
        .lineSpacing(8)
        .padding(.vertical, 4)
    case .largeTitle_SemiBold:
      content
        .font(.system(size: 32))
        .fontWeight(.semibold)
        .lineSpacing(8)
        .padding(.vertical, 4)
    case .largeTitle_Expanded:
      content
        .font(Font(uiFont: uiFontExpanded(fontsize: 32, weight: .semibold)))
        .lineSpacing(8)
        .padding(.vertical, 4)
    case .title1:
      content
        .font(.system(size: 28))
        .lineSpacing(8)
        .padding(.vertical, 4)
    case .title1_SemiBold:
      content
        .font(.system(size: 32))
        .fontWeight(.semibold)
        .lineSpacing(8)
        .padding(.vertical, 4)
    case .title1_Expanded:
      content
        .font(Font(uiFont: uiFontExpanded(fontsize: 28, weight: .semibold)))
        .lineSpacing(8)
        .padding(.vertical, 4)
    case .title2:
      content
        .font(.system(size: 24))
        .lineSpacing(8)
        .padding(.vertical, 4)
    case .title2_SemiBold:
      content
        .font(.system(size: 24))
        .fontWeight(.semibold)
        .lineSpacing(8)
        .padding(.vertical, 4)
    case .title2_Expanded:
      content
        .font(Font(uiFont: uiFontExpanded(fontsize: UIScreen.getWidth(24), weight: .semibold)))
        .lineSpacing(8)
        .padding(.vertical, 4)
    case .subtitle1:
      content
        .font(.system(size: 18, weight: .semibold))
        .lineSpacing(10)
        .padding(.vertical, 5)
    case .subtitle2:
      content
        .font(.system(size: 16, weight: .semibold))
        .lineSpacing(8)
        .padding(.vertical, 4)
    case .subtitle3:
      content
        .font(.system(size: 14, weight: .semibold))
        .lineSpacing(6)
        .padding(.vertical, 3)
    case .body1:
      content
        .font(.system(size: 16))
        .lineSpacing(8)
        .padding(.vertical, 4)
    case .body2:
      content
        .font(.system(size: 14))
        .lineSpacing(3)
        .padding(.vertical, 2)
    case .caption_Regular:
      content
        .font(.system(size: 12))
        .lineSpacing(8)
        .padding(.vertical, 4)
    case .caption_SemiBold:
      content
        .font(.system(size: 12, weight: .semibold))
//        .lineSpacing(8)
        .lineSpacing(6)
//        .padding(.vertical, 4)
        .padding(.vertical, 3)
    case .caption2_Regular:
      content
        .font(.system(size: 10))
        .lineSpacing(6)
        .padding(.vertical, 1)
    }
  }

  func uiFontExpanded(fontsize: CGFloat, weight: UIFont.Weight) -> UIFont {
    UIFont.systemFont(ofSize: fontsize, weight: weight, width: .expanded)
  }
}

// MARK: - Font Family Name

// SF Pro
// === SFPro-Regular
// SF Pro Display
// === SFProDisplay-Semibold
// SF Pro Text
// === SFProText-Regular
// === SFProText-Semibold
// Apple SD Gothic Neo
// === AppleSDGothicNeo-Regular
// === AppleSDGothicNeo-Thin
// === AppleSDGothicNeo-UltraLight
// === AppleSDGothicNeo-Light
// === AppleSDGothicNeo-Medium
// === AppleSDGothicNeo-SemiBold
// === AppleSDGothicNeo-Bold
