//
//  PickerOptionsInfo.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/12/27.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import Photos
import UIKit

// MARK: - PickerOptionsInfo

public struct PickerOptionsInfo {
  /// Theme
  /// - Default: Auto
  public var theme: PickerTheme = .init(style: .auto)

  /// Select Limit
  /// - Default: 1
  public var selectLimit = 1

  /// Column Number
  /// - Default: 4
  public var columnNumber = 3

  /// Auto Calculate Column Number
  /// In iOS column number is `columnNumber`, in iPadOS column number will calculated by device orientation or device size.
  /// - Default: true
  public var autoCalculateColumnNumber = true

  /// - Default: 1200
  public var photoMaxWidth: CGFloat = 1200

  /// Max Width for export Large Photo(When User pick original image)
  /// - Default: 1800
  public var largePhotoMaxWidth: CGFloat = 1800

  /// Allow Use Original Image
  /// - Default: false
  public var allowUseOriginalImage = false

  /// Album Options
  /// - Default: smart album + user create album + shared + userCreated
  public var albumOptions: PickerAlbumOption = [.smart, .userCreated, .shared]

  /// Select Options
  /// - Default: Video
  /// - .photoLive and .photoGIF are subtype of .photo and will be treated as a photo
  /// when not explicitly indicated, otherwise special handling will be possible (playable & proprietary)
  public var selectOptions: PickerSelectOption = [.video]

  /// Selection Tap Action
  /// - Default: Preview
  public var selectionTapAction: PickerSelectionTapAction = .quickPick

  /// Order by date
  /// - Default: DESC
  public var orderByDate: Sort = .desc

  /// Preselect assets
  /// - Default: []
  public var preselectAssets: [String] = []

  /// Disable Rules
  /// - Default: []
  public var disableRules: [AssetDisableCheckRule] = []

  /// Clear all selected assets after switching album
  /// - Default: false
  public var clearSelectionAfterSwitchingAlbum = false

  /// Enable Debug Log
  /// - Default: false
  public var enableDebugLog = false

  public init() {
    #if ANYIMAGEKIT_ENABLE_CAPTURE
    captureOptions.mediaOptions = []
    #endif
  }
}

// MARK: - PickerSelectOption

public struct PickerSelectOption: OptionSet {
  /// Photo
  public static let photo = PickerSelectOption(rawValue: 1 << 0)
  /// Video
  public static let video = PickerSelectOption(rawValue: 1 << 1)
  /// Live Photo
  public static let photoLive = PickerSelectOption(rawValue: 1 << 3)

  public let rawValue: Int

  public init(rawValue: Int) {
    self.rawValue = rawValue
  }

  public var isPhoto: Bool {
    contains(.photo) || contains(.photoLive)
  }

  public var isVideo: Bool {
    contains(.video)
  }
}

extension PickerSelectOption {
  var mediaTypes: [PHAssetMediaType] {
    var result: [PHAssetMediaType] = []
    if contains(.photo) || contains(.photoLive) {
      result.append(.image)
    }
    if contains(.video) {
      result.append(.video)
    }
    return result
  }
}

// MARK: - PickerAlbumOption

public struct PickerAlbumOption: OptionSet {
  /// Smart Album, managed by system
  public static let smart = PickerAlbumOption(rawValue: 1 << 0)
  /// User Created Album
  public static let userCreated = PickerAlbumOption(rawValue: 1 << 1)
  /// Shared Album
  public static let shared = PickerAlbumOption(rawValue: 1 << 2)

  public let rawValue: Int

  public init(rawValue: Int) {
    self.rawValue = rawValue
  }
}

// MARK: - PickerEditorOption

public struct PickerEditorOption: OptionSet {
  /// Photo
  public static let photo = PickerEditorOption(rawValue: 1 << 0)
  /// Video: - TODO
  /* public */ static let video = PickerEditorOption(rawValue: 1 << 1)

  public let rawValue: Int

  public init(rawValue: Int) {
    self.rawValue = rawValue
  }
}

// MARK: - PickerSelectionTapAction

public enum PickerSelectionTapAction: Equatable {
  /// Preview
  /// - Default value
  case preview
  /// Quick pick
  /// - It will select photo instead of show preview controller when you click photo on asset picker controller
  case quickPick
  /// Open editor
  /// - It will open Editor instead of show preview controller when you click photo on asset picker controller
  case openEditor
}

extension PickerSelectionTapAction {
  var hideToolBar: Bool {
    switch self {
    case .quickPick, .openEditor:
      true
    default:
      false
    }
  }
}
