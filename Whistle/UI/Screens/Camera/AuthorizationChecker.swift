//
//  AuthorizationChecker.swift
//  Whistle
//
//  Created by Lee Juwon on 2023/09/21.
//

import AVFoundation
import Foundation

// MARK: - AuthorizationChecker

struct AuthorizationChecker {
  static func checkCaptureAuthorizationStatus() async -> Status {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
      return .permitted

    case .notDetermined:
      let isPermissionGranted = await AVCaptureDevice.requestAccess(for: .video)
      if isPermissionGranted {
        return .permitted
      } else {
        fallthrough
      }

    case .denied:
      fallthrough

    case .restricted:
      fallthrough

    @unknown default:
      return .notPermitted
    }
  }
}

// MARK: AuthorizationChecker.Status

extension AuthorizationChecker {
  enum Status {
    case permitted
    case notPermitted
  }
}
