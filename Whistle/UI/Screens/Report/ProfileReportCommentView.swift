//
//  ProfileReportCommentView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/14/23.
//

import Combine
import SwiftUI

struct ProfileReportCommentView: View {
  @Environment(\.dismiss) var dismiss
  @Environment(\.colorScheme) var colorScheme
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
  let textLimit = 150

  var body: some View {
    VStack(spacing: 0) {
      Divider().frame(width: UIScreen.width)
      Text("이 \(reportCategory == .post ? "콘텐츠를" : "계정을") 신고하는 이유는 무엇인가요?")
        .fontSystem(fontDesignSystem: .subtitle2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundColor(.labelColorPrimary)
        .padding(.top, 16)
        .padding(.bottom, 4)
      Text("이 \(reportCategory == .post ? "콘텐츠를" : "계정을") 신고하는 이유에 대해 추가적인 내용을 알려주세요.")
        .fontSystem(fontDesignSystem: .caption_Regular)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundColor(.labelColorSecondary)
        .padding(.bottom, 16)
      TextField("기타 참고사항을 알려주세요 (선택사항)", text: $inputReportDetail, axis: .vertical)
        .padding(16)
        .frame(height: 160, alignment: .top)
        .contentShape(Rectangle())
        .tint(.Info)
        .focused($isFocused)
        .overlay {
          if colorScheme == .light {
            RoundedRectangle(cornerRadius: 8)
              .stroke(lineWidth: 1)
              .foregroundColor(.labelColorDisablePlaceholder)
          }
        }
        .overlay(alignment: .bottomTrailing) {
          Text("\(inputReportDetail.count)/\(textLimit)자")
            .padding()
            .foregroundStyle(Color.Disable_Placeholder_Light)
            .fontSystem(fontDesignSystem: .body2)
        }
        .onReceive(Just(inputReportDetail)) { _ in
          limitText(textLimit)
        }
        .background(RoundedRectangle(cornerRadius: 8).fill(colorScheme == .dark ? Color.Elevated_Dark : Color.white))
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
    .toolbarBackground(Color.backgroundDefault, for: .navigationBar)
    .toolbarBackground(.visible, for: .navigationBar)
    .foregroundColor(.labelColorPrimary)
    .padding(.horizontal, 16)
    .background(Color.backgroundDefault)
    .toolbarRole(.editor)
    .navigationTitle(CommonWords().report)
    .navigationBarTitleDisplayMode(.inline)
    .navigationDestination(isPresented: $goComplete) {
      ReportCompleteView(goReport: $goReport)
    }
    .toolbar {
      ToolbarItem(placement: .confirmationAction) {
        Button {
          isFocused = false
          alertViewModel.linearAlert(
            isRed: true,
            title: "정말 신고하시겠습니까?",
            cancelText: CommonWords().cancel,
            destructiveText: CommonWords().report)
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
            .fontSystem(fontDesignSystem: .subtitle2)
        }
      }
    }
    .onAppear {
      alertViewModel.onFullScreenCover = true
    }
    .onDisappear {
      alertViewModel.onFullScreenCover = false
    }
  }

  func limitText(_ upper: Int) {
    if inputReportDetail.count > upper {
      inputReportDetail = String(inputReportDetail.prefix(upper))
    }
  }
}
