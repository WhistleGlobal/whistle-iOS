//
//  ProfileEditView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/3/23.
//

import Kingfisher
import Photos
import SwiftUI

// MARK: - ProfileEditView

struct ProfileEditView: View {
  @Environment(\.dismiss) var dismiss
  @StateObject private var tabbarModel = TabbarModel.shared
  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject private var toastViewModel = ToastViewModel.shared
  @StateObject private var alertViewModel = AlertViewModel.shared

  @ObservedObject var photoCollection = PhotoCollection(smartAlbum: .smartAlbumUserLibrary)

  @State var showGallery = false
  @State var showAuthAlert = false
  @State var showAlbumAccessView = false

  @State var editProfileImage = false
  @State var isAlbumAuthorized = false
  @State var authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        profileImageView(url: apiViewModel.myProfile.profileImage, size: 100)
          .padding(.top, 36)
          .padding(.bottom, 16)
        Button {
          if isAlbumAuthorized {
            editProfileImage = true
          } else {
            showAlbumAccessView = true
          }
        } label: {
          Text(ProfileEditWords().photoEdit)
            .foregroundColor(.Info)
            .fontSystem(fontDesignSystem: .subtitle2)
        }
        .padding(.bottom, 40)
        Divider().frame(height: 0.5).padding(.leading, 16).foregroundColor(.labelColorDisablePlaceholder)
        profileEditLink(
          destination: ProfileEditIDView(),
          title: ProfileEditWords().userID,
          content: apiViewModel.myProfile.userName)
        Divider().padding(.leading, 96).foregroundColor(.labelColorDisablePlaceholder)
        profileEditLink(
          destination: ProfileEditIntroduceView(
            introduce: apiViewModel.myProfile.introduce ?? ""),
          title: ProfileEditWords().intro,
          content: apiViewModel.myProfile.introduce ?? "")
        Divider().frame(height: 0.5).padding(.leading, 16).foregroundColor(.labelColorDisablePlaceholder)
        Spacer()
      }
      .toolbarBackground(
        Color.backgroundDefault,
        for: .navigationBar)
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(.visible, for: .navigationBar)
      .background(.backgroundDefault)
      .onAppear {
        toastViewModel.onFullScreenCover = true
        alertViewModel.onFullScreenCover = true
      }
      .overlay {
        if toastViewModel.onFullScreenCover {
          ToastMessageView()
        }
      }
      .fullScreenCover(isPresented: $showGallery) {
        ProfileImagePickerView(photoCollection: photoCollection)
      }
      .fullScreenCover(isPresented: $showAlbumAccessView) {
        AlbumAccessView(isAlbumAuthorized: $isAlbumAuthorized, showAlbumAccessView: $showAlbumAccessView)
      }
      .navigationBarBackButtonHidden()
      .confirmationDialog("", isPresented: $editProfileImage) {
        Button(ProfileEditWords().albumUpload, role: .none) {
          PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            switch status {
            case .notDetermined, .restricted, .denied:
              break
            case .authorized, .limited:
              showGallery = true
            @unknown default:
              break
            }
          }
        }
        Button(ProfileEditWords().setDefaultImage, role: .none) {
          Task {
            await apiViewModel.deleteProfileImage()
            await apiViewModel.requestMyProfile()
          }
        }
        Button(CommonWords().cancel, role: .cancel) { }
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button {
            tabbarModel.showTabbar()
            toastViewModel.onFullScreenCover = false
            toastViewModel.showToast = false
            alertViewModel.onFullScreenCover = false
            dismiss()
          } label: {
            Image(systemName: "xmark")
              .foregroundColor(.labelColorPrimary)
          }
        }
        ToolbarItem(placement: .principal) {
          Text(ProfileEditWords().edit)
            .foregroundStyle(Color.labelColorPrimary)
            .font(.headline)
        }
        ToolbarItem(placement: .confirmationAction) {
          Button {
            tabbarModel.showTabbar()
            toastViewModel.onFullScreenCover = false
            toastViewModel.showToast = false
            alertViewModel.onFullScreenCover = false
            dismiss()
          } label: {
            Text(CommonWords().done)
              .foregroundColor(.Info)
              .fontSystem(fontDesignSystem: .subtitle2)
          }
        }
      }
      .task {
        await apiViewModel.requestMyProfile()
      }
      .onAppear {
        tabbarModel.hideTabbar()
        getAlbumAuth()
      }
    }
    .overlay {
      if alertViewModel.onFullScreenCover {
        AlertPopup().ignoresSafeArea()
      }
    }
  }
}

extension ProfileEditView {
  @ViewBuilder
  func profileEditLink(destination: some View, title: LocalizedStringKey, content: String) -> some View {
    NavigationLink(destination: destination) {
      HStack(spacing: 0) {
        Text(title)
          .multilineTextAlignment(.leading)
          .fontSystem(fontDesignSystem: .subtitle2)
          .foregroundColor(.labelColorPrimary)
          .frame(width: 96, height: 56, alignment: .leading)
        Text(content.isEmpty ? "소개" : content)
          .fontSystem(fontDesignSystem: .body1)
          .foregroundColor(content.isEmpty ? .labelColorDisablePlaceholder : .labelColorPrimary)
          .lineLimit(1)
          .truncationMode(.tail)
          .frame(maxWidth: .infinity, alignment: .leading)

        Image(systemName: "chevron.right")
          .font(.system(size: 16))
          .foregroundColor(Color.Disable_Placeholder_Dark)
      }
      .frame(height: 56)
    }
    .padding(.horizontal, 16)
  }
}

extension ProfileEditView {
  func getAlbumAuth() {
    switch authorizationStatus {
    case .authorized:
      isAlbumAuthorized = true
    case .limited:
      isAlbumAuthorized = true
    default:
      break
    }
  }
}
