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
  @EnvironmentObject var apiViewModel: APIViewModel
  let reportReason: Int
  let contentId: Int
  let uesrId: Int

  var body: some View {
    VStack(spacing: 0) {
      Divider().frame(width: UIScreen.width)
      Text("이 콘텐츠를 신고하는 이유는 무엇인가요?")
        .fontSystem(fontDesignSystem: .subtitle2_KO)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundColor(.LabelColor_Primary)
        .padding(.top, 16)
        .padding(.bottom, 4)
      Text("이 콘텐츠를 신고하는 이유에 대해 추가적인 내용을 알려주세요.")
        .fontSystem(fontDesignSystem: .caption_Regular)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundColor(.LabelColor_Secondary)
        .padding(.bottom, 16)
      TextField("기타 참고사항을 알려주세요 (선택사항)", text: $inputReportDetail)
        .padding(16)
        .frame(height: 160, alignment: .top)
        .frame(maxWidth: .infinity)
        .cornerRadius(8)
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
          Task {
            let reportSuccess = await apiViewModel.reportContent(
              userId: uesrId,
              contentId: contentId,
              reportReason: reportReason,
              reportDescription: inputReportDetail)
            if reportSuccess == 200 {
              goComplete = true
            } else if reportSuccess == 400 {
              log("중복")
              showAlert = false
            } else {
              log("서버 통신 실패")
              showAlert = false
            }
          }
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
          if !showAlert {
            Text("제출")
              .foregroundColor(.Info)
              .fontSystem(fontDesignSystem: .subtitle2_KO)
          }
        }
      }
    }
  }
}
