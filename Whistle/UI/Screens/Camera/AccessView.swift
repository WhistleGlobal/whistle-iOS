//
//  AccessView.swift
//  Whistle
//
//  Created by Lee Juwon on 2023/09/21.
//

import AVFoundation
import Photos
import SwiftUI

struct AccessView: View {
  @State private var isCameraAuthorized = false
  @State private var isAlbumAuthorized = false
  @State private var isMicrophoneAuthorized = false

  var body: some View {
    NavigationView {
      ZStack {
        Image("AccessBackground")
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
          .edgesIgnoringSafeArea(.all)

        VStack(spacing: 156) {
          VStack(spacing: 12) {
            Text("카메라와 마이크에\n접근할 수 있도록 허용해 주세요")
              .fontSystem(fontDesignSystem: .subtitle1_KO)
              .foregroundColor(.LabelColor_Primary_Dark)
              .multilineTextAlignment(.center)

            Text("당신의 휘슬을 기록해 보세요")
              .fontSystem(fontDesignSystem: .body2)
              .foregroundColor(.LabelColor_Secondary_Dark)
          }

          VStack(spacing: 16) {
            Button(action: {
              requestAlbumPermission()
            }) {
              glassMoriphicView(width: UIScreen.width-32, height: 56, cornerRadius: 12)
                .overlay {
                  RoundedRectangle(cornerRadius: 12)
                    .stroke(lineWidth: 1)
                    .foregroundStyle(LinearGradient.Border_Glass)

                  HStack {
                    Image(systemName: "photo.fill")
                      .foregroundColor(.White)
                      .frame(width: 24, height: 24)
                    Text("앨범 읽기/쓰기 허용")
                      .fontSystem(fontDesignSystem: .subtitle2_KO)
                      .foregroundColor(.LabelColor_Primary_Dark)
                  }
                }
            }

            Button(action: {
              requestCameraPermission()
            }) {
              glassMoriphicView(width: UIScreen.width-32, height: 56, cornerRadius: 12)
                .overlay {
                  RoundedRectangle(cornerRadius: 12)
                    .stroke(lineWidth: 1)
                    .foregroundStyle(LinearGradient.Border_Glass)

                  HStack {
                    Image(systemName: "camera.fill")
                      .foregroundColor(.White)
                      .frame(width: 24, height: 24)
                    Text("카메라 엑세스 허용")
                      .fontSystem(fontDesignSystem: .subtitle2_KO)
                      .foregroundColor(.LabelColor_Primary_Dark)
                  }
                }
            }

            Button(action: {
              requestMicrophonePermission()
            }) {
              glassMoriphicView(width: UIScreen.width-32, height: 56, cornerRadius: 12)
                .overlay {
                  RoundedRectangle(cornerRadius: 12)
                    .stroke(lineWidth: 1)
                    .foregroundStyle(LinearGradient.Border_Glass)

                  HStack {
                    Image(systemName: "mic.fill")
                      .foregroundColor(.White)
                      .frame(width: 24, height: 24)
                    Text("마이크 엑세스 허용")
                      .fontSystem(fontDesignSystem: .subtitle2_KO)
                      .foregroundColor(.LabelColor_Primary_Dark)
                  }
                }
            }
          }
          .frame(maxHeight: .infinity)
        }
      }
    }
  }

  private func requestCameraPermission() {
    AVCaptureDevice.requestAccess(for: .video) { granted in
      DispatchQueue.main.async {
        isCameraAuthorized = granted
      }
    }
  }

  private func requestMicrophonePermission() {
    AVCaptureDevice.requestAccess(for: .audio) { granted in
      DispatchQueue.main.async {
        isMicrophoneAuthorized = granted
      }
    }
  }

  private func requestAlbumPermission() {
    PHPhotoLibrary.requestAuthorization { status in
      DispatchQueue.main.async {
        isAlbumAuthorized = status == .authorized
      }
    }
  }

}

#Preview {
  AccessView()
}
