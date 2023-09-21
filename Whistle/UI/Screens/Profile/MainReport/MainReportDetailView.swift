//
//  MainReportDetailView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/21/23.
//

import SwiftUI

struct MainReportDetailView: View {

  @Environment(\.dismiss) var dismiss
  @Binding var goReport: Bool
  @State var goComplete = false
  @State var showAlert = false
  @State var inputReportDetail = ""
  let reportReason: Int

  var body: some View {
    VStack(spacing: 0) {
      Divider().frame(width: UIScreen.width)
      Text("이 콘텐츠를 신고하는 이유는 무엇인가요?")
        .fontSystem(fontDesignSystem: .subtitle2_KO)
        .foregroundColor(.LabelColor_Primary)
        .padding(.bottom, 4)
      Text("이 콘텐츠를 신고하는 이유에 대해 추가적인 내용을 알려주세요.")
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
    .navigationDestination(isPresented: $goComplete) {
      ReportCompleteView(goReport: $goReport)
    }
    .overlay {
      if showAlert {
        ReportAlert {
          showAlert = false
        } reportAction: {
          goComplete = true
        }
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
        Text("신고")
          .fontSystem(fontDesignSystem: .subtitle2_KO)
      }
      ToolbarItem(placement: .confirmationAction) {
        Button {
          showAlert = true
        } label: {
          Text("제출")
            .foregroundColor(.Info)
            .fontSystem(fontDesignSystem: .subtitle2_KO)
        }
      }
    }
  }
}
