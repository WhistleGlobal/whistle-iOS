//
//  MediaType.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/27.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import Foundation
import MobileCoreServices

public enum MediaType: Equatable, CustomStringConvertible {

  case photo
  case video
  case photoLive

  init?(utType: String) {
    let kUTType = utType as CFString
    switch kUTType {
    case kUTTypeImage:
      self = .photo
    case kUTTypeMovie:
      self = .video
    case kUTTypeLivePhoto:
      self = .photoLive
    default:
      return nil
    }
  }

  public var description: String {
    switch self {
    case .photo:
      return "PHOTO"
    case .video:
      return "VIDEO"
    case .photoLive:
      return "PHOTO/LIVE"
    }
  }

  public var utType: String {
    switch self {
    case .photo:
      return kUTTypeImage as String
    case .video:
      return kUTTypeMovie as String
    case .photoLive:
      return kUTTypeLivePhoto as String
    }
  }

  public var isImage: Bool {
    self != .video
  }

  public var isVideo: Bool {
    self == .video
  }
}
