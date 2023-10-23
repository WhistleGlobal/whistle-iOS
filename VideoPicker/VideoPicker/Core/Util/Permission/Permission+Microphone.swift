//
//  Permission+Microphone.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/1/7.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import AVFoundation

extension Permission {
  func _checkMicrophone() -> Status {
    AVAudioSession.sharedInstance().recordPermission._status
  }

  func _requestMicrophone(completion: @escaping PermissionCompletion) {
    guard Bundle.main.object(forInfoDictionaryKey: ._microphoneUsageDescription) != nil else {
      _print("WARNING: \(String._microphoneUsageDescription) not found in Info.plist")
      return
    }

    AVAudioSession.sharedInstance().requestRecordPermission { result in
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

extension AVAudioSession.RecordPermission {
  fileprivate var _status: Permission.Status {
    switch self {
    case .denied:
      .denied
    case .granted:
      .authorized
    default:
      .notDetermined
    }
  }
}

extension String {
  fileprivate static let _microphoneUsageDescription = "NSMicrophoneUsageDescription"
}
