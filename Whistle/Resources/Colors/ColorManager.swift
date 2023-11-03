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
  static let Dim_UltraThin = Color.gray80Light.opacity(0.16)

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
  static let Blue_Disabled = Color("Gray40")

  // MARK: - Button Gray Color

  static let Gray_Default = Color("Gray80").opacity(0.16)
  static let Gray_Pressed = Color("Gray80").opacity(0.36)
  static let Gray_Disabled = Color("Gray80").opacity(0.56)

  static var Border_Default_Dark = Color("Gray20_Dark").opacity(0.36)

  // 위 Alert color와 이름 동일
  // static let Success = Color("Success")
  // static let Info = Color("Info")
  // static let Danger = Color("Danger")
  static var Primary: Color {
    Color.lightAndDarkColor(light: "Gray60", dark: "Gray10")
  }

  static var Secondary: Color {
    Color.lightAndDarkColor(light: "Gray50", dark: "Gray20")
  }

  static var Disable_Placeholder: Color {
    Color.lightAndDarkColor(light: "Gray40", dark: "Gray30")
  }

  static var Disable_Placeholder_Light: Color = .Gray40_Light

  static var Disable_Placeholder_Dark: Color = .Gray30_Dark

  // MARK: - Background_Default

  static var Background_Default: Color {
    Color.lightAndDarkColor(light: "white", dark: "Gray80")
  }

  static var Background_Default_Dark: Color {
    Color("Gray80_Dark")
  }

  // MARK: - Background_Elevated

  static var Elevated: Color {
    Color.lightAndDarkColor(light: "white", dark: "Gray70")
  }

  static var Elevated_Dark: Color {
    Color("Gray60_Dark")
  }

  // MARK: - Border Color

  static var Border_Default: Color {
    Color.lightAndDarkColor(light: "Gray30", dark: "Gray60")
  }

  static var Border_Default_Light = Color.Gray30_Light
  // static var Border_Glass => extension LinearGradient 참고

  // MARK: - Label Color

  static var LabelColor_Primary: Color {
    Color.lightAndDarkColor(light: "Gray60", dark: "Gray10")
  }

  static var LabelColor_Secondary: Color {
    Color.lightAndDarkColor(light: "Gray50", dark: "Gray20")
  }

  static var LabelColor_DisablePlaceholder: Color {
    Color.lightAndDarkColor(light: "Gray40", dark: "Gray30")
  }
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
