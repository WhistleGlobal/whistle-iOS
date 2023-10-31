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
  @StateObject var alertViewModel = AlertViewModel.shared
  @FocusState private var isFocused: Bool

  @State var goComplete = false
  @State var inputReportDetail = ""
  @Binding var goReport: Bool
  @Binding var selectedContentId: Int
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
        .contentShape(Rectangle())
        .tint(.Info)
        .focused($isFocused)
        .overlay {
          RoundedRectangle(cornerRadius: 8)
            .stroke(lineWidth: 1)
            .foregroundColor(.Disable_Placeholder)
        }
        .background(Color.reactiveBackground)
        .onSubmit {
          isFocused = false
        }
        .onTapGesture {
          isFocused = true
        }
      Spacer()
    }
    .onTapGesture {
      isFocused = false
    }
    .padding(.horizontal, 16)
    .background(Color.reactiveBackground)
    .navigationBarBackButtonHidden()
    .navigationTitle("신고")
    .navigationBarTitleDisplayMode(.inline)
    .navigationDestination(isPresented: $goComplete) {
      ReportCompleteView(goReport: $goReport)
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
      ToolbarItem(placement: .confirmationAction) {
        Button {
          isFocused = false
          alertViewModel.linearAlert(
            isRed: true,
            title: "정말 신고하시겠습니까?",
            cancelText: "취소",
            destructiveText: "신고")
          {
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
                  alertViewModel.submitAlert(
                    title: "중복 접수되었습니다.",
                    content: "같은 아이디로 접수된 신고 사유가 있습니다.",
                    submitText: "확인")
                } else {
                  alertViewModel.submitAlert(
                    title: "신고 처리 중 문제가 생겼습니다. 잠시후 다시 시도해주세요.",
                    submitText: "확인")
                }
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
                  alertViewModel.submitAlert(
                    title: "중복 접수되었습니다.",
                    content: "같은 아이디로 접수된 신고 사유가 있습니다.",
                    submitText: "확인")
                } else {
                  alertViewModel.submitAlert(
                    title: "신고 처리 중 문제가 생겼습니다. 잠시후 다시 시도해주세요.",
                    submitText: "확인")
                }
              }
            }
          }
        } label: {
          Text(CommonWords().submit)
            .foregroundColor(.Info)
            .fontSystem(fontDesignSystem: .subtitle2_KO)
            .opacity(alertViewModel.showAlert ? 0.3 : 1)
            .grayscale(alertViewModel.showAlert ? 0.5 : 0)
        }
        .disabled(alertViewModel.showAlert)
      }
    }
    .onAppear {
      alertViewModel.onFullScreenCover = true
    }
    .onDisappear {
      alertViewModel.onFullScreenCover = false
    }
    .overlay {
      if alertViewModel.onFullScreenCover {
        AlertPopup()
      }
    }
  }
}
