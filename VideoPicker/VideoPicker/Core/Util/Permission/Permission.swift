//
//  Permission.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/1/7.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import Foundation

typealias PermissionCompletion = (Permission.Status) -> Void

// MARK: - Permission

enum Permission: Equatable {
  case photos
  case camera
  case microphone

  var status: Status {
    switch self {
    case .photos:
      _checkPhotos()
    case .camera:
      _checkCamera()
    case .microphone:
      _checkMicrophone()
    }
  }

  func request(completion: @escaping PermissionCompletion) {
    switch self {
    case .photos:
      _requestPhotos(completion: completion)
    case .camera:
      _requestCamera(completion: completion)
    case .microphone:
      _requestMicrophone(completion: completion)
    }
  }
}

extension Permission {
  var localizedTitleKey: StringConfigKey {
    switch self {
    case .photos:
      .photos
    case .camera:
      .camera
    case .microphone:
      .microphone
    }
  }

  var localizedAlertMessageKey: StringConfigKey {
    switch self {
    case .photos:
      .noPhotosPermissionTips
    case .camera:
      .noCameraPermissionTips
    case .microphone:
      .noMicrophonePermissionTips
    }
  }
}

// MARK: Permission.Status

extension Permission {
  enum Status: Equatable {
    case notDetermined
    case denied
    case authorized
    case limited // Photos only
  }
}
