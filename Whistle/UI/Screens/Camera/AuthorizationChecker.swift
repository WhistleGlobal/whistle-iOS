//
//  AuthorizationChecker.swift
//  Whistle
//
//  Created by Lee Juwon on 2023/09/21.
//

// import AVFoundation
// import Foundation
//
//// MARK: - AuthorizationChecker
//
// struct AuthorizationChecker {
//  static func checkCaptureAuthorizationStatus() async -> Status {
//    switch AVCaptureDevice.authorizationStatus(for: .video) {
//    case .authorized:
//      return .permitted
//
//    case .notDetermined:
//      let isPermissionGranted = await AVCaptureDevice.requestAccess(for: .video)
//      if isPermissionGranted {
//        return .permitted
//      } else {
//        fallthrough
//      }
//
//    case .denied:
//      fallthrough
//
//    case .restricted:
//      fallthrough
//
//    @unknown default:
//      return .notPermitted
//    }
//  }
// }
//
//// MARK: AuthorizationChecker.Status
//
// extension AuthorizationChecker {
//  enum Status {
//    case permitted
//    case notPermitted
//  }
// }

import AVFoundation
import Photos

struct AuthorizationChecker {
  static func checkCaptureAuthorizationStatus() async
    -> (cameraAuthorized: Bool, albumAuthorized: Bool, microphoneAuthorized: Bool)
  {
    let cameraAuthorized = AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    let albumAuthorized = PHPhotoLibrary.authorizationStatus() == .authorized
    let microphoneAuthorized = AVCaptureDevice.authorizationStatus(for: .audio) == .authorized
    return (cameraAuthorized, albumAuthorized, microphoneAuthorized)
  }

  static func checkAccess() async -> (cameraAuthorized: Bool, albumAuthorized: Bool, microphoneAuthorized: Bool) {
    // 카메라, 앨범 및 마이크 권한을 확인하는 로직
    let cameraAuthorized = true
    let albumAuthorized = true
    let microphoneAuthorized = true
    return (cameraAuthorized, albumAuthorized, microphoneAuthorized)
  }
}
