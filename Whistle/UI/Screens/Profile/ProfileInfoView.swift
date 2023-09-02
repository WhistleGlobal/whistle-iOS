//
//  ProfileInfoView.swift
//  Whistle
//
//  Created by ChoiYujin on 8/31/23.
//

import SwiftUI

struct ProfileInfoView: View {

  @Environment(\.dismiss) var dismiss
  @Binding var isShowingBottomSheet: Bool


  var body: some View {
    VStack(spacing: 0) {
      Circle()
        .frame(width: 100, height: 100)
        .padding(.top, 36)
        .padding(.bottom, 16)
      Text("UserName")
        .foregroundColor(.LabelColor_Primary)
        .fontSystem(fontDesignSystem: .title2_Expanded)
      List {
        LabeledContent {
          Text("2019.11.12")
            .fontSystem(fontDesignSystem: .body1)
            .foregroundColor(Color.Disable_Placeholder)
        } label: {
          Text("가입한 날짜")
            .fontSystem(fontDesignSystem: .body1)
            .foregroundColor(Color.LabelColor_Primary)
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
