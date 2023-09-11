//
//  ProfileReportView.swift
//  Whistle
//
//  Created by ChoiYujin on 8/31/23.
//

import SwiftUI

struct ProfileReportView: View {

  @Environment(\.dismiss) var dismiss
  @EnvironmentObject var apiViewModel: APIViewModel
  @Binding var isShowingBottomSheet: Bool
  // FIXME: - Report 관련 모델로 변경할 것
  @State var reports: [Any] = []

  var body: some View {
    VStack(spacing: 0) {
      if reports.isEmpty {
        Text("회원님의 콘텐츠는\n 현재 영향을 받지 않습니다.")
          .fontSystem(fontDesignSystem: .subtitle1_KO)
          .foregroundColor(.LabelColor_Primary)
          .multilineTextAlignment(.center)
          .padding(.bottom, 12)
        Text("커뮤니티 가이드라인을 준수해주셔서 감사합니다.")
          .fontSystem(fontDesignSystem: .body2_KO)
          .foregroundColor(.LabelColor_Secondary)
      } else {
        Divider()
        Text("회원님의 계정 또는 콘텐츠가 가이드라인을 준수하지 않아 Whistle이 적용한 조치를 확인해보세요.")
          .fontSystem(fontDesignSystem: .caption_Regular)
          .foregroundColor(.LabelColor_Secondary)
          .frame(height: 60)
        Divider()
        List {
          reportRow(title: "폭력적 위협", dateString: "34분 전")
          reportRow(title: "사생활 침해", dateString: "2022. 1. 5. 오후 5:38")
          reportRow(title: "권리 침해 또는 사이버 괴롭힘", dateString: "2020. 3. 15. 오후 8:40")
        }
        .listStyle(.plain)
      }
    }
    .navigationBarBackButtonHidden()
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle("신고")
    .onAppear {
      isShowingBottomSheet = false
    }
    .task {
      await apiViewModel.requestReportedConent()
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

  @ViewBuilder
  func reportRow(title: String, dateString: String) -> some View {
    HStack {
      Rectangle()
        .foregroundColor(.black)
        .frame(width: 60, height: 60)
        .cornerRadius(8)
      VStack(spacing: 4) {
        Text(title)
          .frame(maxWidth: .infinity, alignment: .leading)
          .foregroundColor(.black)
          .fontSystem(fontDesignSystem: .subtitle1_KO)
        Text(dateString)
          .frame(maxWidth: .infinity, alignment: .leading)
          .fontSystem(fontDesignSystem: .body2_KO)
          .foregroundColor(.LabelColor_Secondary)
          .lineLimit(1)
      }
    }
  }
}
