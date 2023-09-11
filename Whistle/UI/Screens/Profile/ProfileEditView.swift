//
//  ProfileEditView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/3/23.
//

import Kingfisher
import SwiftUI

// MARK: - ProfileEditView

struct ProfileEditView: View {

  @Environment(\.dismiss) var dismiss
  @State var editProfileImage = false
  @State var showToast = false
  @State var showGallery = false
  @StateObject var photoViewModel = PhotoViewModel()
  @EnvironmentObject var apiViewModel: APIViewModel

  var body: some View {
    VStack(spacing: 0) {
      Divider()
        .frame(width: UIScreen.width)
        .padding(.bottom, 36)
      KFImage.url(URL(string: apiViewModel.myProfile.profileImage ?? ""))
        .placeholder { // 플레이스 홀더 설정
          Image("ProfileDefault")
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
        }
        .resizable()
        .scaledToFill()
        .frame(width: 100, height: 100)
        .clipShape(Circle())
        .padding(.bottom, 16)
      Button {
        editProfileImage = true
      } label: {
        Text("프로필 사진 수정")
          .foregroundColor(.Info)
          .fontSystem(fontDesignSystem: .subtitle2_KO)
      }
      .padding(.bottom, 40)
      Divider()
      profileEditLink(
        destination: ProfileEditIDView(showToast: $showToast).environmentObject(apiViewModel),
        title: "사용자 ID",
        content: apiViewModel.myProfile.userName)
      Divider().padding(.leading, 96)
      profileEditLink(
        destination: ProfileEditIntroduceView(showToast: $showToast, introduce: $apiViewModel.myProfile.introduce)
          .environmentObject(apiViewModel),
        title: "소개",
        content: apiViewModel.myProfile.introduce)
      Divider()
      Spacer()
    }
    .overlay {
      ProfileToastMessage(text: "소개가 수정되었습니다.", showToast: $showToast)
    }
    .fullScreenCover(isPresented: $showGallery) {
      CustomPhotoView()
        .environmentObject(photoViewModel)
        .environmentObject(apiViewModel)
    }
    .padding(.horizontal, 16)
    .navigationBarBackButtonHidden()
    .confirmationDialog("", isPresented: $editProfileImage) {
      Button("갤러리에서 사진 업로드", role: .none) {
        photoViewModel.fetchPhotos()
        showGallery = true
      }
      Button("기본 이미지로 변경", role: .none) {
        Task {
          await apiViewModel.deleteProfileImage()
          await apiViewModel.requestMyProfile()
        }
      }
      Button("취소", role: .cancel) {
        log("Cancel")
      }
    }
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button {
          dismiss()
        } label: {
          Image(systemName: "chevron.backward")
            .foregroundColor(.LabelColor_Primary)
        }
      }
      ToolbarItem(placement: .principal) {
        Text("프로필 편집")
          .fontSystem(fontDesignSystem: .subtitle2_KO)
      }
      ToolbarItem(placement: .confirmationAction) {
        Button {
          log("Update Profile")
          dismiss()
        } label: {
          Text("완료")
            .foregroundColor(.Info)
            .fontSystem(fontDesignSystem: .subtitle2_KO)
        }
      }
    }
    .task {
      await apiViewModel.requestMyProfile()
    }
  }
}

extension ProfileEditView {

  @ViewBuilder
  func profileEditLink(destination: some View, title: String, content: String) -> some View {
    NavigationLink(destination: destination) {
      HStack(spacing: 0) {
        Text(title)
          .fontSystem(fontDesignSystem: .subtitle1_KO)
          .foregroundColor(.LabelColor_Primary)
          .frame(width: 96, height: 56, alignment: .leading)
        Text(content.isEmpty ? "소개" : content)
          .fontSystem(fontDesignSystem: .body1_KO)
          .foregroundColor(content.isEmpty ? .Disable_Placeholder : .LabelColor_Primary)
          .frame(maxWidth: .infinity, alignment: .leading)

        Image(systemName: "chevron.right")
          .resizable()
          .scaledToFit()
          .frame(width: 12, height: 16)
          .foregroundColor(.secondary)
      }
      .frame(height: 56)
    }
  }
}
