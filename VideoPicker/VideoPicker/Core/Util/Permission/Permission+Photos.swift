//
//  Permission+Photos.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/1/7.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import Photos

extension Permission {
  func _checkPhotos() -> Status {
    if #available(iOS 14.0, *) {
      return PHPhotoLibrary.authorizationStatus(for: .readWrite)._status
    } else {
      return PHPhotoLibrary.authorizationStatus()._status
    }
  }

  func _requestPhotos(completion _: @escaping PermissionCompletion) {
    guard Bundle.main.object(forInfoDictionaryKey: ._photoLibraryUsageDescription) != nil else {
      _print("WARNING: \(String._photoLibraryUsageDescription) not found in Info.plist")
      return
    }

//    if #available(iOS 14.0, *) {
//      PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
//        Thread.runOnMain {
//          completion(status._status)
//        }
//      }
//    } else {
//      PHPhotoLibrary.requestAuthorization { status in
//        Thread.runOnMain {
//          completion(status._status)
//        }
//      }
//    }
  }
}

extension PHAuthorizationStatus {
  fileprivate var _status: Permission.Status {
    switch self {
    case .notDetermined:
      .notDetermined
    case .authorized:
      .authorized
    case .limited:
      .limited
    default:
      .denied
    }
  }
}

extension String {
  fileprivate static let _photoLibraryUsageDescription = "NSPhotoLibraryUsageDescription"
}
