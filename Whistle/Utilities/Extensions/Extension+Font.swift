//
//  Extension+Font.swift
//  Whistle
//
//  Created by ChoiYujin on 8/29/23.
//

import SwiftUI

extension Font {
  // MARK: Lifecycle

  public init(uiFont: UIFont) {
    self = Font(uiFont as CTFont)
  }

  // MARK: Public

  public static func registerFonts(fontName: String) {
    registerFont(
      bundle: Bundle.main,
      fontName: fontName,
      fontExtension: ".otf") // change according to your ext.
  }

  public static func registerFontsTTF(fontName: String) {
    registerFont(
      bundle: Bundle.main,
      fontName: fontName,
      fontExtension: ".ttf") // change according to your ext.
  }

  // MARK: Fileprivate

  fileprivate static func registerFont(bundle: Bundle, fontName: String, fontExtension: String) {
    guard
      let fontURL = bundle.url(forResource: fontName, withExtension: fontExtension),
      let fontDataProvider = CGDataProvider(url: fontURL as CFURL),
      let font = CGFont(fontDataProvider)
    else {
      fatalError("Couldn't create font from data")
    }

    var error: Unmanaged<CFError>?

    CTFontManagerRegisterGraphicsFont(font, &error)
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
