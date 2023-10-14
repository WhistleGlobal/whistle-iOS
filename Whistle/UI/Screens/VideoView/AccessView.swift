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
  @State var showAlert = false
  @State var opacity = 0.1

  @Binding var isCameraAuthorized: Bool
  @Binding var isAlbumAuthorized: Bool
  @Binding var isMicrophoneAuthorized: Bool

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
          Button {
            videoUsageAuth = .photoLibraryAccess
            showAlert = true
          } label: {
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
          .overlay {
            if isAlbumAuthorized {
              RoundedRectangle(cornerRadius: 12)
                .foregroundColor(.black.opacity(0.4))
            }
          }
          .disabled(isAlbumAuthorized)
          Button {
            videoUsageAuth = .cameraAccess
            showAlert = true
          } label: {
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
          .overlay {
            if isCameraAuthorized {
              RoundedRectangle(cornerRadius: 12)
                .foregroundColor(.black.opacity(0.4))
            }
          }
          .disabled(isCameraAuthorized)
          Button {
            videoUsageAuth = .microphoneAccess
            showAlert = true
          } label: {
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
          .overlay {
            if isMicrophoneAuthorized {
              RoundedRectangle(cornerRadius: 12)
                .foregroundColor(.black.opacity(0.4))
            }
          }
          .disabled(isMicrophoneAuthorized)
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
        title: Text("설정"),
        message: Text("Whistle이 \(videoUsageAuth.rawValue)이 허용되어 있지않습니다.\r\n 설정화면으로 가시겠습니까?"),
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
    .opacity(opacity)
    .onAppear {
      withAnimation {
        opacity = 1.0
      }
    }
  }
}

private var videoUsageAuth: VideoUsageAuth = .none

// MARK: - VideoUsageAuth

enum VideoUsageAuth: String {
  case photoLibraryAccess = "엘범 접근 권한"
  case cameraAccess = "카메라 접근 권한"
  case microphoneAccess = "마이크 접근 권한"
  case none = ""
}
