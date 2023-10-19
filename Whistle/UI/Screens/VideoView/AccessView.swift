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
  @EnvironmentObject var tabbarModel: TabbarModel
  @State var showAlert = (false, VideoUsageAuth.none)
  @State var opacity = 0.1

  @Binding var isCameraAuthorized: Bool
  @Binding var isMicrophoneAuthorized: Bool

  var body: some View {
    ZStack {
      Color.clear.overlay {
        Image("DefaultBG")
          .resizable()
          .scaledToFill()
          .blur(radius: 50)
      }
      VStack(spacing: 0) {
        Spacer()
        Text("Whistle의 카메라 및 마이크\n액세스를 허용해 주세요")
          .fontSystem(fontDesignSystem: .title2_KO_SemiBold)
          .foregroundColor(.LabelColor_Primary_Dark)
          .multilineTextAlignment(.center)
          .padding(.bottom, 64)

        Group {
          labelTitleAndText(
            systemImage: "photo.fill.on.rectangle.fill",
            title: "회원님이 이 권한을 사용하는 방식",
            text: "회원님이 Whistle에 15초 이내의 짧은 동영상을 녹화하고 오디오 효과를 미리 볼 수 있습니다.")
          labelTitleAndText(
            systemImage: "info.circle",
            title: "이 권한이 사용되는 방식",
            text: "회원님이 Whistle에 직접 촬영한 동영상을 공유하고 오디오 효과를 적용할 수 있도록 지원하며 이에 대한 미리보기를 보여줍니다.")
          labelTitleAndText(
            systemImage: "gear",
            title: "이 설정 사용 방법",
            text: "설정에서 언제든지 권한을 변경할 수 있습니다.")
        }
        .padding(.bottom, 36)

        Spacer()
        VStack(spacing: 16) {
          Button {
            requestCameraPermission()
            requestMicrophonePermission()
            showAuthAlert()
          } label: {
            glassMorphicView(width: UIScreen.width - 32, height: 56, cornerRadius: 12)
              .overlay {
                RoundedRectangle(cornerRadius: 12)
                  .stroke(lineWidth: 1)
                  .foregroundStyle(LinearGradient.Border_Glass)
                Text("계속")
                  .fontSystem(fontDesignSystem: .subtitle2_KO)
                  .foregroundColor(.LabelColor_Primary_Dark)
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
    .alert(isPresented: $showAlert.0) {
      Alert(
        title: Text("'Whistle'에 대해 \(showAlert.1.rawValue)이 없습니다. 설정에서 \(showAlert.1.rawValue) 권한을 켜시겠습니까?"),
        primaryButton: .default(Text("설정으로 가기"), action: {
          guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
          if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
          }
        }),
        secondaryButton: .cancel())
    }
  }
}

private var videoUsageAuth: VideoUsageAuth = .none

// MARK: - VideoUsageAuth

enum VideoUsageAuth: String {
  case photoLibraryAccess = "라이브러리 읽기/쓰기 권한"
  case cameraAccess = "카메라 사용 권한"
  case microphoneAccess = "마이크 사용 권한"
  case cameraAndMicrophoneAcess = "카메라/마이크 사용 권한"
  case none = ""
}

extension AccessView {
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

  private func showAuthAlert() {
    if !isCameraAuthorized {
      showAlert.1 = .cameraAccess
      showAlert.0 = true
    } else if !isMicrophoneAuthorized {
      showAlert.1 = .microphoneAccess
      showAlert.0 = true
    } else { }
  }

}

extension AccessView {
  @ViewBuilder
  func labelTitleAndText(systemImage: String, title: String, text: String) -> some View {
    HStack(alignment: .top, spacing: 16) {
      Image(systemName: systemImage)
        .font(.system(size: 20))
        .frame(width: 24, height: 24)
        .foregroundColor(.LabelColor_Primary_Dark)

      VStack(alignment: .leading, spacing: 8) {
        Text(title)
          .fontSystem(fontDesignSystem: .subtitle3_KO)
          .foregroundColor(.LabelColor_Primary_Dark)
        Text(text)
          .fontSystem(fontDesignSystem: .caption_KO_Regular)
          .lineLimit(nil)
          .multilineTextAlignment(.leading)
          .fixedSize(horizontal: false, vertical: true)
          .foregroundColor(.LabelColor_Secondary_Dark)
      }
      Spacer()
    }
    .padding(.horizontal, 56)
  }
}
