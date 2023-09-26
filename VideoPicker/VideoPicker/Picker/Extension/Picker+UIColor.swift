//
//  Picker+UIColor.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/9/17.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

extension UIColor {

  // MARK: - main color
  static var primaryColor: UIColor {
    UIColor.color(hex: 0x57BE6A)
  }

  // MARK: - main text
  static var primaryText: UIColor {
    UIColor.create(light: primaryTextLight, dark: primaryTextDark)
  }

  static var primaryTextLight: UIColor {
    UIColor.color(hex: 0x333333)
  }

  static var primaryTextDark: UIColor {
    UIColor.color(hex: 0xEAEAEA)
  }

  // MARK: - sub text
  static var subText: UIColor {
    UIColor.create(light: subTextLight, dark: subTextDark)
  }

  static var subTextLight: UIColor {
    UIColor.color(hex: 0x999999)
  }

  static var subTextDark: UIColor {
    UIColor.color(hex: 0x6E6E6E)
  }

  // MARK: - toolBar
  static var toolBar: UIColor {
    UIColor.create(light: toolBarLight, dark: toolBarDark)
  }

  static var toolBarLight: UIColor {
    UIColor.color(hex: 0xF7F7F7)
  }

  static var toolBarDark: UIColor {
    UIColor.color(hex: 0x31302F)
  }

  // MARK: - background
  static var background: UIColor {
    UIColor.create(light: backgroundLight, dark: backgroundDark)
  }

  static var backgroundLight: UIColor {
    UIColor.color(hex: 0xFFFFFF)
  }

  static var backgroundDark: UIColor {
    UIColor.color(hex: 0x31302F)
  }

  // MARK: - selected cell
  static var selectedCell: UIColor {
    UIColor.create(light: selectedCellLight, dark: selectedCellDark)
  }

  static var selectedCellLight: UIColor {
    UIColor.color(hex: 0xE4E5E9)
  }

  static var selectedCellDark: UIColor {
    UIColor.color(hex: 0x171717)
  }
}
