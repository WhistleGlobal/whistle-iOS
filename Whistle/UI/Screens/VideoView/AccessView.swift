//
//  AccessView.swift
//  Whistle
//
//  Created by ChoiYujin on 10/11/23.
//

import AVFoundation
import Photos
import SwiftUI

// MARK: - AccessView

struct AccessView: View {
  @State var showAlert = false
  @Binding var isCameraAuthorized: Bool
  @Binding var isAlbumAuthorized: Bool
  @Binding var isMicrophoneAuthorized: Bool
  @Binding var isNavigationActive: Bool
  @EnvironmentObject var apiViewModel: APIViewModel
  @EnvironmentObject var tabbarModel: TabbarModel

  var body: some View {
    ZStack {
      Color.clear.overlay {
        Image("DefaultBG")
          .resizable()
          .scaledToFill()
          .blur(radius: 50)
      }
      VStack {
        Spacer()
        VStack(spacing: 12) {
          Text("카메라와 마이크에\n접근할 수 있도록 허용해 주세요")
            .fontSystem(fontDesignSystem: .subtitle1_KO)
            .foregroundColor(.LabelColor_Primary_Dark)
            .multilineTextAlignment(.center)

          Text("당신의 휘슬을 기록해 보세요")
            .fontSystem(fontDesignSystem: .body2)
            .foregroundColor(.LabelColor_Secondary_Dark)
        }
        Spacer()
          .frame(height: 156)

        VStack(spacing: 16) {
          Button(action: {
            showAlert = true
            checkAllPermissions()
          }) {
            glassMorphicView(width: UIScreen.width - 32, height: 56, cornerRadius: 12)
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
            showAlert = true
            checkAllPermissions()
          }) {
            glassMorphicView(width: UIScreen.width - 32, height: 56, cornerRadius: 12)
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
            showAlert = true
            checkAllPermissions()
          }) {
            glassMorphicView(width: UIScreen.width - 32, height: 56, cornerRadius: 12)
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
      }
      VStack {
        HStack {
          Button {
            tabbarModel.tabSelectionNoAnimation = .main
            withAnimation {
              tabbarModel.tabSelection = .main
            }
          } label: {
            Image(systemName: "xmark")
              .resizable()
              .scaledToFit()
              .frame(width: 20)
              .foregroundColor(.white)
          }
          Spacer()
        }
        .frame(height: 52)
        .padding(.horizontal, 16)
        Spacer()
      }
    }
    .alert(isPresented: $showAlert) {
      Alert(
        title: Text("권한 없음"),
        message: Text("권한 없어요."),
        primaryButton: .cancel {
          log("update")
        }
        ,secondaryButton: .default(Text("설정으로 가기"), action: {
          guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
          if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
          }
        }))
    }
  }
}

extension AccessView {
  private func requestPermissions() {
    // Request camera, album, and microphone permissions
    requestCameraPermission()
    requestAlbumPermission()
    requestMicrophonePermission()
  }

  private func requestAlbumPermission() {
    PHPhotoLibrary.requestAuthorization { status in
      DispatchQueue.main.async {
        isAlbumAuthorized = status == .authorized
        checkAllPermissions()
      }
    }
  }

  private func requestCameraPermission() {
    AVCaptureDevice.requestAccess(for: .video) { granted in
      DispatchQueue.main.async {
        isCameraAuthorized = granted
        checkAllPermissions()
      }
    }
  }

  private func requestMicrophonePermission() {
    AVCaptureDevice.requestAccess(for: .audio) { granted in
      DispatchQueue.main.async {
        isMicrophoneAuthorized = granted
        checkAllPermissions()
      }
    }
  }

  private func checkAllPermissions() {
    if isAlbumAuthorized, isCameraAuthorized, isMicrophoneAuthorized {
      isNavigationActive = true
    }
  }
}
