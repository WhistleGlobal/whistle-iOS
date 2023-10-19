//
//  AlbumAccessView.swift
//  Whistle
//
//  Created by ChoiYujin on 10/19/23.
//

import AVFoundation
import Photos
import SwiftUI

// MARK: - AlbumAccessView

struct AlbumAccessView: View {

  let authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
  @State var showAlert = false
  @Binding var isAlbumAuthorized: Bool
  @Binding var showAlbumAccessView: Bool

  var body: some View {
    ZStack {
      Color.clear.overlay {
        Image("DefaultBG")
          .resizable()
          .scaledToFill()
          .blur(radius: 50)
      }
      VStack(spacing: 0) {
        HStack {
          Button {
            showAlbumAccessView = false
          } label: {
            Image(systemName: "xmark")
              .font(.system(size: 20))
              .foregroundColor(.White)
              .padding(.vertical, 16)
              .padding(.horizontal, 18)
          }
          Spacer()
        }
        .frame(height: 52)
        .frame(maxWidth: .infinity)
        Spacer()
        Text("Whistle의 사진 및 동영상 액세스를 허용해 주세요")
          .fontSystem(fontDesignSystem: .title2_KO_SemiBold)
          .foregroundColor(.LabelColor_Primary_Dark)
          .multilineTextAlignment(.center)
          .padding(.bottom, 64)

        Group {
          labelTitleAndText(
            systemImage: "photo.fill.on.rectangle.fill",
            title: "회원님이 이 권한을 사용하는 방식",
            text: "Whistle에 카메라 롤의 사진과 동영상을 추가하여 효과를 미리 볼 수 있습니다.")
          labelTitleAndText(
            systemImage: "info.circle",
            title: "이 권한이 사용되는 방식",
            text: "회원님이 Whistle에 카메라 롤의 사진과 동영상을 공유하고 오디오 효과를 적용할 수 있도록 지원하며 이에 대한 미리보기를 보여줍니다.")
          labelTitleAndText(
            systemImage: "gear",
            title: "이 설정 사용 방법",
            text: "설정에서 언제든지 권한을 변경할 수 있습니다.")
        }
        .padding(.bottom, 36)

        Spacer()
        VStack(spacing: 16) {
          Button {
            requestAlbumAuthorization()
            if isAlbumAuthorized {
              showAlbumAccessView = false
            }
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
    }
    .alert(isPresented: $showAlert) {
      Alert(
        title: Text("'Whistle'에 대해 라이브러리 읽기/쓰기 권한이 없습니다. 설정에서 라이브러리 읽기/쓰기 권한을 켜시겠습니까?"),
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

extension AlbumAccessView {

  private func requestAlbumAuthorization() {
    switch authorizationStatus {
    case .notDetermined:
      PHPhotoLibrary.requestAuthorization { status in
        DispatchQueue.main.async {
          switch status {
          case .restricted:
            print("restricted")
          case .denied:
            print("denied")
          case .authorized:
            isAlbumAuthorized = true
            showAlbumAccessView = false
          case .limited:
            print("limited")
          @unknown default:
            print("unknown default")
          }
        }
      }
    case .restricted:
      print("restricted")
    case .denied:
      showAlert = true
    case .authorized:
      isAlbumAuthorized = true
      showAlbumAccessView = false
    case .limited:
      print("limited")
    @unknown default:
      print("unknown default")
    }
  }
}

extension AlbumAccessView {
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