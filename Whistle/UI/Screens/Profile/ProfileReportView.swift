//
//  ProfileReportView.swift
//  Whistle
//
//  Created by ChoiYujin on 8/31/23.
//

import SwiftUI

struct ProfileReportView: View {

  @Environment(\.dismiss) var dismiss
  @Binding var isShowingBottomSheet: Bool


  var body: some View {
    List {
      reportRow()
      reportRow()
      reportRow()
      reportRow()
    }
    .listStyle(.plain)
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle("신고")
    .onAppear {
      isShowingBottomSheet = false
    }
  }


  @ViewBuilder
  func reportRow() -> some View {
    HStack {
      Rectangle()
        .foregroundColor(.black)
        .frame(width: 60, height: 60)
        .cornerRadius(8)
      VStack(spacing: 4) {
        Text("영상 제목")
          .frame(maxWidth: .infinity, alignment: .leading)
          .foregroundColor(.black)
          .fontSystem(fontDesignSystem: .subtitle1_KO)
        Text("신고사유신고사유신고사유신고사유신고사유신고사유신고사유신고사유신고사유신고사유신고사유신고사유")
          .frame(maxWidth: .infinity, alignment: .leading)
          .fontSystem(fontDesignSystem: .body2_KO)
          .foregroundColor(.LabelColor_Secondary)
          .lineLimit(1)
      }
    }
  }
}
