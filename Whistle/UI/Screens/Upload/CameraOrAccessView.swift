//
//  CameraOrAccessView.swift
//  Whistle
//
//  Created by 박상원 on 11/1/23.
//

import AVFoundation
import SwiftUI

// MARK: - CameraOrAccessView

struct CameraOrAccessView: View {
  @Binding var isCam: Bool
  @Binding var isMic: Bool
  @Binding var isNav: Bool

  var body: some View {
    NavigationView {
      if isCam, isMic {
        VideoCaptureView()
      } else {
        if !isNav {
          RecordAccessView(
            isCameraAuthorized: $isCam,
            isMicrophoneAuthorized: $isMic)
        }
      }
    }
    .tint(Color.LabelColor_Primary)
    .onAppear {
      getCameraPermission()
      getMicrophonePermission()
      checkAllPermissions()
    }
  }
}

extension CameraOrAccessView {
  private func getCameraPermission() {
    let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    switch authorizationStatus {
    case .authorized:
      isCam = true
    default:
      break
    }
  }

  private func getMicrophonePermission() {
    let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .audio)
    switch authorizationStatus {
    case .authorized:
      isMic = true
    default:
      break
    }
  }

  private func checkAllPermissions() {
    if isCam, isMic {
      isNav = true
    } else {
      isNav = false
    }
  }
}
