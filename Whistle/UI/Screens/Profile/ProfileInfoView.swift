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
  @EnvironmentObject var userViewModel: UserViewModel


  var body: some View {
    VStack(spacing: 0) {
      KFImage.url(URL(string: userViewModel.myProfile.profileImage))
        .placeholder { // 플레이스 홀더 설정
          Circle().frame(width: 100, height: 100)
        }.retry(maxCount: 3, interval: .seconds(5)) // 재시도
        .loadDiskFileSynchronously()
        .cacheMemoryOnly()
        .resizable()
        .scaledToFill()
        .frame(width: 100, height: 100)
        .clipShape(Circle())
        .padding(.top, 36)
        .padding(.bottom, 16)
      Text(userViewModel.myProfile.userName)
        .foregroundColor(.LabelColor_Primary)
        .fontSystem(fontDesignSystem: .title2_Expanded)
        .padding(.bottom, 36)
      List {
        NavigationLink {
          EmptyView()
        } label: {
          Text("가입한 날짜")
            .listRowSeparator(.hidden)
        }
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
