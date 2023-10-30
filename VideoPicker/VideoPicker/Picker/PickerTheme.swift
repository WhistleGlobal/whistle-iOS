//
//  PickerTheme.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/4/2.
//  Copyright © 2021-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

// MARK: - PickerTheme

/// UI Theme for Picker
public final class PickerTheme: ThemeConfigurable {
  /// User Interface Style
  public let style: UserInterfaceStyle

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

  public init(style: UserInterfaceStyle) {
    self.style = style
  }

  /// Set custom color
  /// - Note: Please set dynamic color if your app support dark mode
  public subscript(color key: ColorConfigKey) -> UIColor {
    get { colors[key] ?? key.defaultValue(for: style) }
    set { colors[key] = newValue }
  }

  /// Set custom icon
  /// - Note: Please set dynamic image if your app support dark mode
  public subscript(icon key: IconConfigKey) -> UIImage? {
    get { icons[key] ?? key.defaultValue(for: style) }
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

// MARK: PickerTheme.ColorConfigKey

extension PickerTheme {
  public enum ColorConfigKey: Hashable {
    /// Primary Color
    case primary

    /// Text Color
    case whiteText

    /// black Color
    case blackText

    /// Sub Text Color
    case subText

    /// ToolBar Color
    case toolBar

    /// Background Color
    case background

    /// TableView Cell Selected Background Color
    case selectedCell

    func defaultValue(for style: UserInterfaceStyle) -> UIColor {
      switch style {
      case .auto:
        switch self {
        case .primary: UIColor.primaryColor
        // album title text color
        case .whiteText: UIColor.white
        case .blackText: UIColor.black
        case .subText: UIColor.subText
        case .toolBar: UIColor.toolBar
        case .background: UIColor.background
        case .selectedCell: UIColor.selectedCell
        }
      case .light:
        switch self {
        case .primary: UIColor.primaryColor
        case .whiteText: UIColor.white
        case .blackText: UIColor.black
        case .subText: UIColor.subTextLight
        case .toolBar: UIColor.toolBarLight
        case .background: UIColor.backgroundLight
        case .selectedCell: UIColor.selectedCellLight
        }
      case .dark:
        switch self {
        case .primary: UIColor.primaryColor
        case .whiteText: UIColor.white
        case .blackText: UIColor.black
        case .subText: UIColor.subTextDark
        case .toolBar: UIColor.toolBarDark
        case .background: UIColor.backgroundDark
        case .selectedCell: UIColor.selectedCellDark
        }
      }
    }
  }
}

// MARK: PickerTheme.IconConfigKey

extension PickerTheme {
  public enum IconConfigKey: Hashable {
    /// 20*20, Light/Dark
    case albumArrow

    /// 20*20, Light/Dark
    case arrowRight

    /// 50*50
    case camera

    /// 16*16
    case checkOff

    /// 16*16, Template
    case checkOn

    /// 20*20
    case iCloud

    /// 20*20, Light/Dark
    case livePhoto

    /// 20*20
    case photoEdited

    /// 24*24, Light/Dark
    case pickerCircle

    /// 14*24, Light/Dark
    case returnButton

    /// 24*15
//        case video

    /// 80*80
    case videoPlay

    /// 20*20, Light/Dark
    case warning

    func defaultValue(for style: UserInterfaceStyle) -> UIImage? {
      switch self {
      case .albumArrow:
//        return BundleHelper.image(named: "AlbumArrow", style: style, module: .picker)
        UIImage(systemName: "chevron.down")
      case .arrowRight:
//        return BundleHelper.image(named: "ArrowRight", style: style, module: .picker)
        UIImage(systemName: "chevron.right")
      case .camera:
        BundleHelper.image(named: "Camera", module: .picker)
      case .checkOff:
        BundleHelper.image(named: "CheckOff", module: .picker)
      case .checkOn:
        BundleHelper.image(named: "CheckOn", module: .picker)?.withRenderingMode(.alwaysTemplate)
      case .iCloud:
        BundleHelper.image(named: "iCloud", module: .picker)
      case .livePhoto:
        BundleHelper.image(named: "LivePhoto", style: style, module: .picker)
      case .photoEdited:
        BundleHelper.image(named: "PhotoEdited", module: .picker)
      case .pickerCircle:
        BundleHelper.image(named: "PickerCircle", style: style, module: .picker)
      case .returnButton:
        BundleHelper.image(named: "ReturnButton", style: style, module: .picker)
//            case .video:
//                return BundleHelper.image(named: "", module: .picker)
      case .videoPlay:
        BundleHelper.image(named: "VideoPlay", module: .picker)
      case .warning:
        BundleHelper.image(named: "Warning", style: style, module: .picker)
      }
    }
  }
}

// MARK: - String

extension PickerTheme {
  private func defaultStringValue(for key: StringConfigKey) -> String {
    BundleHelper.localizedString(key: key.rawValue, module: .picker)
  }
}

extension StringConfigKey {
  public static let pickerOriginalImage = StringConfigKey(rawValue: "ORIGINAL_IMAGE")
  public static let pickerSelectPhoto = StringConfigKey(rawValue: "SELECT_PHOTO")
  public static let pickerUnselectPhoto = StringConfigKey(rawValue: "UNSELECT_PHOTO")
  public static let pickerTakePhoto = StringConfigKey(rawValue: "TAKE_PHOTO")
  public static let pickerSelectMaximumOfPhotos = StringConfigKey(rawValue: "SELECT_A_MAXIMUM_OF_PHOTOS")
  public static let pickerSelectMaximumOfVideos = StringConfigKey(rawValue: "SELECT_A_MAXIMUM_OF_VIDEOS")
  public static let pickerSelectMaximumOfPhotosOrVideos = StringConfigKey(rawValue: "SELECT_A_MAXIMUM_OF_PHOTOS_OR_VIDEOS")
  public static let pickerDownloadingFromiCloud = StringConfigKey(rawValue: "DOWNLOADING_FROM_ICLOUD")
  public static let pickerFetchFailedPleaseRetry = StringConfigKey(rawValue: "FETCH_FAILED_PLEASE_RETRY")
  public static let pickerA11ySwitchAlbumTips = StringConfigKey(rawValue: "A11Y_SWITCH_ALBUM_TIPS")
  public static let pickerLimitedPhotosPermissionTips = StringConfigKey(rawValue: "LIMITED_PHOTOS_PERMISSION_TIPS")
  public static let pickerCannotPreviewAssetInOtherAlbum = StringConfigKey(rawValue: "CANNOT_PREVIEW_ASSET_IN_OTHER_ALBUM")
}

// MARK: - Label

extension PickerTheme {
  struct LabelConfigObject: Equatable {
    let key: LabelConfigKey
    let configuration: (UILabel) -> Void

    static func == (lhs: PickerTheme.LabelConfigObject, rhs: PickerTheme.LabelConfigObject) -> Bool {
      lhs.key == rhs.key
    }
  }

  public enum LabelConfigKey: Hashable {
    case permissionLimitedTips
    case permissionDeniedTips

    case albumTitle
    case albumCellTitle
    case albumCellSubTitle

    case assetCellVideoDuration

    case selectedNumber
    case selectedNumberInPreview

    case livePhotoMark
    case loadingFromiCloudTips
    case loadingFromiCloudProgress
  }
}

// MARK: - Button

extension PickerTheme {
  struct ButtonConfigObject: Equatable {
    let key: ButtonConfigKey
    let configuration: (UIButton) -> Void

    static func == (lhs: PickerTheme.ButtonConfigObject, rhs: PickerTheme.ButtonConfigObject) -> Bool {
      lhs.key == rhs.key
    }
  }

  public enum ButtonConfigKey: Hashable {
    case preview
    case edit
    case originalImage
    case done
    case backInPreview
    case goSettings
  }
}
