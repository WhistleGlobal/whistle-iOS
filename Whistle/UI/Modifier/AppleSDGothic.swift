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

extension Font {

  // MARK: Lifecycle

  public init(uiFont: UIFont) {
    self = Font(uiFont as CTFont)
  }

  // MARK: Public

  public static func expanded(
    _ style: UIFont.TextStyle,
    size: CGFloat? = nil,
    weight: Font.Weight = .regular)
    -> Font
  {
    var descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
    let traits: [UIFontDescriptor.TraitKey: Any] = [.width: 1.2]
    descriptor = descriptor.addingAttributes([.traits: traits])
    let uiFont = UIFont(descriptor: descriptor, size: size ?? descriptor.pointSize)
    log(uiFont.fontName)
    log(uiFont.familyName)
    return Font(uiFont: uiFont).weight(weight)
  }

  public func expanded(
    _ style: UIFont.TextStyle,
    size: CGFloat? = nil,
    weight: Font.Weight = .regular)
    -> Font
  {
    var descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
    let traits: [UIFontDescriptor.TraitKey: Any] = [.width: 1.2]
    descriptor = descriptor.addingAttributes([.traits: traits])
    let uiFont = UIFont(descriptor: descriptor, size: size ?? descriptor.pointSize)

    log(uiFont.fontName)
    log(uiFont.familyName)
    log(uiFont.fontDescriptor)
    return Font(uiFont: uiFont).weight(weight)
  }
}
