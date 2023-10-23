//
//  Permission+Camera.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/1/7.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import AVFoundation

extension Permission {
  func _checkCamera() -> Status {
    AVCaptureDevice.authorizationStatus(for: .video)._status
  }

  func _requestCamera(completion: @escaping PermissionCompletion) {
    guard Bundle.main.object(forInfoDictionaryKey: ._cameraUsageDescription) != nil else {
      _print("WARNING: \(String._cameraUsageDescription) not found in Info.plist")
      return
    }

    AVCaptureDevice.requestAccess(for: .video) { result in
      Thread.runOnMain {
        if result {
          completion(.authorized)
        } else {
          completion(.denied)
        }
      }
    }
  }
}

extension AVAuthorizationStatus {
  fileprivate var _status: Permission.Status {
    switch self {
    case .authorized:
      .authorized
    case .notDetermined:
      .notDetermined
    default:
      .denied
    }
  }
}

extension String {
  fileprivate static let _cameraUsageDescription = "NSCameraUsageDescription"
}
