//
//  ProfileReportCommentView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/14/23.
//

import SwiftUI

struct ProfileReportCommentView: View {
  @Environment(\.dismiss) var dismiss
  @StateObject var apiViewModel = APIViewModel.shared
  @Binding var goReport: Bool
  @Binding var selectedContentId: Int
  @State var goComplete = false
  @State var showAlert = false
  @State var inputReportDetail = ""
  @State var showDuplication = false
  @State var showFailLoad = false
  let reportCategory: ProfileReportTypeSelectionView.ReportCategory
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
      TextField("기타 참고사항을 알려주세요 (선택사항)", text: $inputReportDetail, axis: .vertical)
        .padding(16)
        .frame(height: 160, alignment: .top)
        .frame(maxWidth: UIScreen.width - 32)
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
        AlertPopup(alertStyle: .linear, title: "정말 신고하시겠습니까?", cancelText: "취소", destructiveText: "신고") {
          showAlert = false
        } destructiveAction: {
          if reportCategory == .post {
            Task {
              let reportSuccess = await apiViewModel.reportContent(
                userID: userId,
                contentID: selectedContentId,
                reportReason: reportReason,
                reportDescription: inputReportDetail)
              if reportSuccess == 200 {
                goReport = true
                goComplete = true
              } else if reportSuccess == 400 {
                showDuplication = true
              } else {
                showFailLoad = true
              }
              showAlert = false
            }
          } else {
            Task {
              let statusCode = await apiViewModel.reportUser(
                usedID: userId,
                contentID: apiViewModel.memberFeed.isEmpty ? 0 : selectedContentId,
                reportReason: reportReason,
                reportDescription: inputReportDetail)
              if statusCode == 200 {
                goReport = true
                goComplete = true
              } else if statusCode == 400 {
                showDuplication = true
              } else {
                showFailLoad = true
              }
              showAlert = false
            }
          }
        }
      }
      if showDuplication {
        AlertPopup(
          alertStyle: .submit,
          title: "중복 접수되었습니다.",
          content: "같은 아이디로 접수된 신고 사유가 있습니다.",
          submitText: "확인",
          submitAction: {
            showDuplication = false
          })
      }
      if showFailLoad {
        AlertPopup(
          alertStyle: .submit,
          title: "신고 처리 중 문제가 생겼습니다. 잠시후 다시 시도해주세요.",
          submitText: "확인",
          submitAction: {
            showFailLoad = false
          })
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
          if !showAlert, !showDuplication, !showFailLoad {
            Text("제출")
              .foregroundColor(.Info)
              .fontSystem(fontDesignSystem: .subtitle2_KO)
          }
        }
      }
    }
  }
}
