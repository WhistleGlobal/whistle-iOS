//
//  ReportDetailView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/14/23.
//

import SwiftUI

struct ReportDetailView: View {

  @Environment(\.dismiss) var dismiss
  @Binding var goReport: Bool
  @State var inputReportDetail = ""

  var body: some View {
    VStack(spacing: 0) {
      Divider().frame(width: UIScreen.width)
      Text("이 계정을 신고하는 이유는 무엇인가요?")
        .fontSystem(fontDesignSystem: .subtitle2_KO)
        .foregroundColor(.LabelColor_Primary)
        .padding(.bottom, 4)
      Text("이 계정을 신고하는 이유에 대해 추가적인 내용을 알려주세요.")
        .fontSystem(fontDesignSystem: .caption_Regular)
        .foregroundColor(.LabelColor_Secondary)
      TextField("기타 참고사항을 알려주세요 (선택사항)", text: $inputReportDetail)
        .cornerRadius(8)
        .padding(16)
        .frame(height: 160, alignment: .top)
        .frame(maxWidth: .infinity)
        .overlay {
          RoundedRectangle(cornerRadius: 8)
            .stroke(lineWidth: 1)
            .foregroundColor(.Disable_Placeholder)
        }

      Spacer()
    }
    .padding(.horizontal, 16)
    .navigationBarBackButtonHidden()
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
        Text("신고")
          .fontSystem(fontDesignSystem: .subtitle2_KO)
      }
      ToolbarItem(placement: .principal) {
        Button {
          goReport = false
        } label: {
          Text("제출")
            .foregroundColor(.Info)
            .fontSystem(fontDesignSystem: .subtitle2_KO)
        }
      }
    }
  }
}
