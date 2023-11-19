//
//  ColorManager.swift
//  Whistle
//
//  Created by 박상원 on 2023/08/23.
//

import SwiftUI

extension Color {
  // MARK: - Primary

  static let Primary_Lighten = Color("Primary_Lighten")
  static let Primary_Default = Color("Primary_Default")
  static let Primary_Default_Dark = Color("Primary_Default_Dark")
  static let Primary_Darken = Color("Primary_Darken")

  // MARK: - Secondary

  static let Secondary_Lighten = Color("Secondary_Lighten")
  static let Secondary_Default = Color("Secondary_Default")
  static let Secondary_Default_Dark = Color("Secondary_Default_Dark")
  static let Secondary_Darken = Color("Secondary_Darken")

  // MARK: - Alert

  static let Success = Color("Success")
  static let Info = Color("Info")
  static let Danger = Color("Danger")
  static let Warning = Color("Warning")

  // MARK: - Labels

  static let Emphasized = Color("Primary_Default")
  // FIXME: - BackgroundBlur 100와 같게 .blur 값 적용하기
  static var Default_Glass = Color("Gray60").opacity(0.48).blur(radius: 10) as! Color

  // FIXME: - BackgroundBlur 100와 같게 .blur 값 적용하기
  static var Elevated_Glass = Color("Gray30").opacity(0.24).blur(radius: 10) as! Color

  // MARK: - Dim Color

  static let Dim_Thick = Color("Gray80").opacity(0.84)
  static let Dim_Default = Color("Gray80").opacity(0.56)
  static let Dim_Default_Light = Color("Gray80_Light").opacity(0.56)
  static let Dim_Thin = Color("Gray80").opacity(0.36)

  static let LabelColor_Primary_Dark: Color = .white
  static let LabelColor_Primary_Light: Color = .init("Gray10_Light")
  static let LabelColor_Secondary_Dark: Color = .init("Gray10_Dark")

  // MARK: - etc

  static let Gray10 = Color("Gray10")
  static let Gray10_Dark = Color("Gray10_Dark")
  static let Gray20_Light = Color("Gray20_Light")
  static let Gray30 = Color("Gray30")
  static let Gray30_Light = Color("Gray30_Light")
  static let Gray30_Dark = Color("Gray30_Dark")
  static let Gray40 = Color("Gray40")
  static let Gray40_Light = Color("Gray40_Light")
  static let Gray50_Dark = Color("Gray50_Dark")
  static let Gray60_Light = Color("Gray60_Light")
  static let Gray60_Dark = Color("Gray60_Dark")
  static let Gray70_Dark = Color("Gray70_Dark")

  // MARK: - Button Blue Color

  static let Blue_Default = Color("Primary_Default")
  static let Blue_Pressed = Color("Primary_Lighten")
  static let Blue_Disabled = Color("Gray30_Light")

  // MARK: - Button Gray Color

  static let Gray_Default = Color("Gray80").opacity(0.16)
  static let Gray_Pressed = Color("Gray80").opacity(0.36)
  static let Gray_Disabled = Color("Gray80").opacity(0.56)

  static var Border_Default_Dark = Color("Gray20_Dark").opacity(0.36)

  static var Disable_Placeholder_Light: Color = .Gray40_Light

  static var Disable_Placeholder_Dark: Color = .Gray30_Dark

  static var Background_Default_Dark: Color {
    Color("Gray80_Dark")
  }

  static var Elevated_Dark: Color {
    Color("Gray60_Dark")
  }

  // MARK: - Border Color
  static var Border_Default_Light = Color.Gray30_Light
  // static var Border_Glass => extension LinearGradient 참고

  static var LabelColor_DisablePlaceholder_Dark: Color = Gray30_Dark
}

extension LinearGradient {
  static var Border_Glass = LinearGradient(
    gradient: Gradient(colors: [Color.white.opacity(0.48), Color.white.opacity(0.16)]),
    startPoint: .top, endPoint: .bottom)

  static var primaryGradient = LinearGradient(
    colors: [.Primary_Default_Dark, .Secondary_Default_Dark],
    startPoint: .leading,
    endPoint: .trailing)
}

// MARK: - MyTeamGradient

extension LinearGradient {

  static var samsungGradient = LinearGradient(
    gradient: Gradient(colors: [Color(hex: 0x2A62AB), Color(hex: 0x1E4194)]),
    startPoint: .top, endPoint: .bottom)

  static var doosanGradient = LinearGradient(
    gradient: Gradient(colors: [Color(hex: 0x2D3858), Color(hex: 0x3C4164), Color(hex: 0x151432)]),
    startPoint: .topLeading, endPoint: .bottomTrailing)

  static var kiwoomGradient = LinearGradient(
    gradient: Gradient(colors: [Color(hex: 0x310006), Color(hex: 0x82222E), Color(hex: 0x50050A)]),
    startPoint: .topLeading, endPoint: .bottomTrailing)

  static var ssgGradient = LinearGradient(
    gradient: Gradient(colors: [Color(hex: 0x7E0C12), Color(hex: 0xCF0A2C)]),
    startPoint: .top, endPoint: .bottom)

  static var hanwhaGradient = LinearGradient(
    gradient: Gradient(colors: [Color(hex: 0x383835), Color(hex: 0x26282A), Color(hex: 0x070706)]),
    startPoint: .topTrailing, endPoint: .bottomLeading)

  static var ktGradient = LinearGradient(
    gradient: Gradient(colors: [Color(hex: 0x464143), Color(hex: 0x000000)]),
    startPoint: .top, endPoint: .bottom)

  static var lotteGradient = LinearGradient(
    gradient: Gradient(colors: [Color(hex: 0x0B2242), Color(hex: 0x334169), Color(hex: 0x00132E)]),
    startPoint: .topLeading, endPoint: .bottomTrailing)

  static var ncGradient = LinearGradient(
    gradient: Gradient(colors: [Color(hex: 0x0D1D3B), Color(hex: 0x678DB7)]),
    startPoint: .top, endPoint: .bottom)

  static var lgGradient = LinearGradient(
    gradient: Gradient(colors: [Color(hex: 0x2F343F), Color(hex: 0x595D61)]),
    startPoint: .top, endPoint: .bottom)

  static var kiaGradient = LinearGradient(
    gradient: Gradient(colors: [Color(hex: 0x091231), Color(hex: 0x08141E)]),
    startPoint: .top, endPoint: .bottom)
}

extension Color {
  static func lightAndDarkColor(light: String, dark: String) -> Color {
    if UITraitCollection.current.userInterfaceStyle == .dark {
      Color(dark)
    } else {
      if light == "white" {
        Color.white
      } else {
        Color(light)
      }
    }
  }
}

extension Color {
  init(hex: Int, opacity: Double = 1.0) {
    let red = Double((hex >> 16) & 0xff) / 255
    let green = Double((hex >> 8) & 0xff) / 255
    let blue = Double((hex >> 0) & 0xff) / 255
    self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
  }
}
