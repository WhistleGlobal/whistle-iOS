//
//  ReportDetailView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/14/23.
//

import SwiftUI

struct ReportDetailView: View {

  @Environment(\.dismiss) var dismiss
  @EnvironmentObject var apiViewModel: APIViewModel
  @Binding var goReport: Bool
  @Binding var selectedContentId: Int
  @State var goComplete = false
  @State var showAlert = false
  @State var inputReportDetail = ""
  @State var showDuplication = false
  @State var showFailLoad = false
  let reportCategory: ReportUserView.ReportCategory
  let reportReason: Int
  let userId: Int

  var body: some View {
    VStack(spacing: 0) {
      Divider().frame(width: UIScreen.width)
      Text("이 \(reportCategory == .post ? "콘텐츠를" : "계정을") 신고하는 이유는 무엇인가요?")
        .fontSystem(fontDesignSystem: .subtitle2_KO)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundColor(.LabelColor_Primary)
        .padding(.top, 16)
        .padding(.bottom, 4)
      Text("이 \(reportCategory == .post ? "콘텐츠를" : "계정을") 신고하는 이유에 대해 추가적인 내용을 알려주세요.")
        .fontSystem(fontDesignSystem: .caption_Regular)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundColor(.LabelColor_Secondary)
        .padding(.bottom, 16)
      TextField("기타 참고사항을 알려주세요 (선택사항)", text: $inputReportDetail)
        .padding(16)
        .frame(height: 160, alignment: .top)
        .frame(maxWidth: .infinity)
        .cornerRadius(8)
        .tint(.Info)
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
          if reportCategory == .post {
            Task {
              let reportSuccess = await apiViewModel.reportContent(
                userId: userId,
                contentId: selectedContentId,
                reportReason: reportReason,
                reportDescription: inputReportDetail)
              if reportSuccess == 200 {
                goReport = true
                goComplete = true
              } else if reportSuccess == 400 {
                showDuplication = true
                log(showDuplication)
              } else {
                showFailLoad = true
              }
            }
          } else {
            Task {
              let statusCode = await apiViewModel.reportUser(
                usedId: userId,
                contentId: apiViewModel.userPostFeed.isEmpty ? 0 : selectedContentId,
                reportReason: reportReason,
                reportDescription: inputReportDetail)
                log(statusCode)
                log(type(of: statusCode))
              if statusCode == 200 {
                goReport = true
                goComplete = true
              } else if statusCode == 400 {
                  showDuplication = true
                  log(showDuplication)
              } else {
                showFailLoad = true
              }
              showAlert = false
            }
          }
        }
      }
    }
    .alert(isPresented: $showDuplication) {
      Alert(
        title: Text("같은 사유로 한 번만 신고할 수 있습니다."),
        message: Text("같은 사유로 신고가 중복되어 신청이 취소되었습니다."),
        dismissButton: .cancel(Text("확인")))
    }
    .alert(isPresented: $showFailLoad) {
      Alert(
        title: Text("신고 처리 중 문제가 생겼습니다. 잠시후 다시 시도해주세요."),
        dismissButton: .cancel(Text("확인")))
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
