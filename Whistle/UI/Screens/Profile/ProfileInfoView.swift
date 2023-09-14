//
//  ProfileInfoView.swift
//  Whistle
//
//  Created by ChoiYujin on 8/31/23.
//

import Kingfisher
import SwiftUI

struct ProfileInfoView: View {

  @Environment(\.dismiss) var dismiss
  @Binding var isShowingBottomSheet: Bool
  @EnvironmentObject var apiViewModel: APIViewModel

  var body: some View {
    VStack(spacing: 0) {
      profileImageView(url: apiViewModel.myProfile.profileImage, size: 100)
        .padding(.top, 36)
        .padding(.bottom, 16)
      Text(apiViewModel.myProfile.userName)
        .foregroundColor(.LabelColor_Primary)
        .fontSystem(fontDesignSystem: .title2_Expanded)
        .padding(.bottom, 36)
      List {
        HStack {
          Text("가입한 날짜")
          Spacer()
          Text("\(apiViewModel.userCreatedDate)")
            .fontSystem(fontDesignSystem: .body1_KO)
            .foregroundColor(.Disable_Placeholder)
        }
        .listRowSeparator(.hidden)
        NavigationLink {
          EmptyView()
        } label: {
          Text("개인정보처리방침")
            .listRowSeparator(.hidden)
        }
        NavigationLink {
          EmptyView()
        } label: {
          Text("이용약관")
            .listRowSeparator(.hidden)
        }
      }
      .listStyle(.plain)
      Spacer()
    }
    .navigationBarBackButtonHidden()
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle("정보")
    .task {
      apiViewModel.requestUserCreateDate()
    }
    .onAppear {
      isShowingBottomSheet = false
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
    }
  }
}
