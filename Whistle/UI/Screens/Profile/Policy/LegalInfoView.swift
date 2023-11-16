//
//  LegalInfoView.swift
//  Whistle
//
//  Created by ChoiYujin on 8/31/23.
//

import Kingfisher
import SwiftUI

struct LegalInfoView: View {
  @Environment(\.dismiss) var dismiss
  @StateObject var apiViewModel = APIViewModel.shared

  var body: some View {
    VStack(spacing: 0) {
      profileImageView(url: apiViewModel.myProfile.profileImage, size: 100)
        .padding(.top, 36)
        .padding(.bottom, 16)
      Text(apiViewModel.myProfile.userName)
        .foregroundColor(.labelColorPrimary)
        .fontSystem(fontDesignSystem: .title2_Expanded)
        .padding(.bottom, 36)
      VStack(spacing: 0) {
        Divider().frame(height: 0.5).padding(.leading, 16)
          .foregroundColor(.labelColorDisablePlaceholder)
        HStack {
          Text("가입한 날짜")
            .fontSystem(fontDesignSystem: .subtitle2)
            .foregroundColor(.labelColorPrimary)
          Spacer()
          Text("\(apiViewModel.userCreatedDate)")
            .fontSystem(fontDesignSystem: .body1)
            .foregroundColor(.labelColorDisablePlaceholder)
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        Divider().frame(height: 0.5).padding(.leading, 16)
          .foregroundColor(.labelColorDisablePlaceholder)
        NavigationLink {
          PrivacyPolicyView().background(.backgroundDefault)
        } label: {
          HStack {
            Text("개인정보처리방침")
              .fontSystem(fontDesignSystem: .subtitle2)
              .foregroundColor(.labelColorPrimary)
            Spacer()
            Image(systemName: "chevron.forward")
              .font(.system(size: 16))
              .foregroundColor(.Disable_Placeholder_Dark)
          }
          .frame(height: 56)
          .id(UUID())
        }
        .padding(.horizontal, 16)
        Divider().frame(height: 0.5).padding(.leading, 16)
          .foregroundColor(.labelColorDisablePlaceholder)
        NavigationLink {
          TermsOfServiceView().background(.backgroundDefault)
        } label: {
          HStack {
            Text("이용약관")
              .fontSystem(fontDesignSystem: .subtitle2)
              .foregroundColor(.labelColorPrimary)
            Spacer()
            Image(systemName: "chevron.forward")
              .font(.system(size: 16))
              .foregroundColor(.Disable_Placeholder_Dark)
          }
          .frame(height: 56)
          .id(UUID())
        }
        .padding(.horizontal, 16)
        Divider().frame(height: 0.5).padding(.leading, 16)
          .foregroundColor(.labelColorDisablePlaceholder)
      }
      Spacer()
    }
    .toolbarBackground(
      Color.backgroundDefault,
      for: .navigationBar)
    .toolbarBackground(.visible, for: .navigationBar)
    .toolbarRole(.editor)
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle(CommonWords().about)
    .task {
      apiViewModel.requestUserCreateDate()
    }
  }
}
