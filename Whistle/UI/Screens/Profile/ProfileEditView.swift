//
//  ProfileEditView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/3/23.
//

import SwiftUI

// MARK: - ProfileEditView

struct ProfileEditView: View {

  @Environment(\.dismiss) var dismiss
  @State var editProfileImage = false


  var body: some View {
    VStack(spacing: 0) {
      Circle()
        .frame(width: 100, height: 100)
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
      profileEditLink(destination: EmptyView(), title: "사용자 ID", content: "East_Road")
      Divider()
        .padding(.leading, 96)
      profileEditLink(destination: EmptyView(), title: "소개", content: "어쩌구 저쩌구")
      Divider()
      Spacer()
    }
    .padding(.horizontal, 16)
    .navigationBarBackButtonHidden()
    .confirmationDialog("", isPresented: $editProfileImage) {
      Button("갤러리에서 사진 업로드", role: .none) {
        log("Show photo ibrary")
      }
      Button("기본 이미지로 변경", role: .none) {
        log("Set defaultImage")
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
          Image(systemName: "xmark")
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
        } label: {
          Text("완료")
            .foregroundColor(.Info)
            .fontSystem(fontDesignSystem: .subtitle2_KO)
        }
      }
    }
  }
}

#Preview {
  NavigationStack {
    ProfileEditView()
  }
}

extension ProfileEditView {

  @ViewBuilder
  func profileEditLink(destination: some View, title: String, content: String) -> some View {
    NavigationLink(destination: destination) {
      HStack(spacing: 0) {
        Text(title)
          .frame(width: 96, height: 56, alignment: .leading)
          .font(.system(size: 16))
          .foregroundColor(.primary)

        Text(content)
          .frame(maxWidth: .infinity, alignment: .leading)
          .font(.body)
          .foregroundColor(.primary)

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
