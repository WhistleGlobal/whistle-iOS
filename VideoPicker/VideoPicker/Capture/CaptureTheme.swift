//
//  CaptureTheme.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2021/11/8.
//  Copyright © 2021-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

// MARK: - CaptureTheme

/// UI Theme for Capture
public final class CaptureTheme: ThemeConfigurable {

  /// Custom color storage
  private var colors: [ColorConfigKey: UIColor] = [:]

  /// Custom icon storage
  private var icons: [IconConfigKey: UIImage] = [:]

  /// Custom string storage
  private var strings: [StringConfigKey: String] = [:]

  /// Config label
  var labelConfiguration: [LabelConfigKey: LabelConfigObject] = [:]

  /// Config button
  var buttonConfiguration: [ButtonConfigKey: ButtonConfigObject] = [:]

  public init() { }

  /// Set custom color
  public subscript(color key: ColorConfigKey) -> UIColor {
    get { colors[key] ?? key.defaultValue() }
    set { colors[key] = newValue }
  }

  /// Set custom icon
  public subscript(icon key: IconConfigKey) -> UIImage? {
    get { icons[key] ?? key.defaultValue() }
    set { icons[key] = newValue }
  }

  /// Set custom string
  /// - Note: Please set localized text if your app support multiple languages
  public subscript(string key: StringConfigKey) -> String {
    get { strings[key] ?? defaultStringValue(for: key) }
    set { strings[key] = newValue }
  }

  /// Configuration Label if you needed
  /// - Note: ⚠️ DO NOT set hidden/enable properties
  public func configurationLabel(for key: LabelConfigKey, configuration: @escaping ((UILabel) -> Void)) {
    labelConfiguration[key] = LabelConfigObject(key: key, configuration: configuration)
  }

  /// Configuration Button if you needed
  /// - Note: ⚠️ DO NOT set hidden/enable properties
  public func configurationButton(for key: ButtonConfigKey, configuration: @escaping ((UIButton) -> Void)) {
    buttonConfiguration[key] = ButtonConfigObject(key: key, configuration: configuration)
  }
}

// MARK: CaptureTheme.ColorConfigKey

extension CaptureTheme {

  public enum ColorConfigKey: Hashable {

    /// Main Color
    case primary

    /// Focus view
    case focus

    func defaultValue() -> UIColor {
      switch self {
      case .primary:
        return UIColor.color(hex: 0x57BE6A)
      case .focus:
        return UIColor.color(hex: 0xFFD60A)
      }
    }
  }
}

// MARK: CaptureTheme.IconConfigKey

extension CaptureTheme {

  public enum IconConfigKey: String, Hashable {

    /// 48*48
    case cameraSwitch = "CameraSwitch"
    /// 27*27
    case captureSunlight = "CaptureSunlight"

    func defaultValue() -> UIImage? {
      BundleHelper.image(named: rawValue, module: .capture)
    }
  }
}

// MARK: - String
extension CaptureTheme {

  private func defaultStringValue(for key: StringConfigKey) -> String {
    BundleHelper.localizedString(key: key.rawValue, module: .capture)
  }
}

extension StringConfigKey {

  public static let captureSwitchToFrontCamera = StringConfigKey(rawValue: "SWITCH_TO_FRONT_CAMERA")
  public static let captureSwitchToBackCamera = StringConfigKey(rawValue: "SWITCH_TO_BACK_CAMERA")
  public static let captureTapForPhoto = StringConfigKey(rawValue: "TAP_FOR_PHOTO")
  public static let captureHoldForVideo = StringConfigKey(rawValue: "HOLD_FOR_VIDEO")
  public static let captureHoldForVideoTapForPhoto = StringConfigKey(rawValue: "HOLD_FOR_VIDEO_TAP_FOR_PHOTO")
}

// MARK: - Label
extension CaptureTheme {

  struct LabelConfigObject: Equatable {
    let key: LabelConfigKey
    let configuration: (UILabel) -> Void

    static func == (lhs: CaptureTheme.LabelConfigObject, rhs: CaptureTheme.LabelConfigObject) -> Bool {
      lhs.key == rhs.key
    }
  }

  public enum LabelConfigKey: Hashable {

    case tips
  }
}

// MARK: - Button
extension CaptureTheme {

  struct ButtonConfigObject: Equatable {
    let key: ButtonConfigKey
    let configuration: (UIButton) -> Void

    static func == (lhs: CaptureTheme.ButtonConfigObject, rhs: CaptureTheme.ButtonConfigObject) -> Bool {
      lhs.key == rhs.key
    }
  }

  public enum ButtonConfigKey: Hashable {

    case cancel
    case switchCamera
  }
}
