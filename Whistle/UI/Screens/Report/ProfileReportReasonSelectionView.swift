//
//  ProfileReportReasonSelectionView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/14/23.
//

import SwiftUI

// MARK: - ProfileReportReasonSelectionView

struct ProfileReportReasonSelectionView: View {
  @Environment(\.dismiss) var dismiss
  @StateObject var apiViewModel = APIViewModel.shared
  @State var goComplete = false
  @Binding var goReport: Bool
  @Binding var selectedContentId: Int
  let userId: Int
  let reportCategory: ProfileReportTypeSelectionView.ReportCategory

  var body: some View {
    VStack(spacing: 0) {
      Divider().frame(width: UIScreen.width)
      Text(reportCategory == .user ? "이 계정을 신고하는 이유는 무엇인가요?" : "이 콘텐츠를 신고하는 이유는 무엇인가요?")
        .fontSystem(fontDesignSystem: .subtitle2_KO)
        .foregroundColor(.LabelColor_Primary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 16)
        .padding(.bottom, 4)
      Text("지식재산권 침해를 신고하는 경우를 제외하고 회원님의 신고는 익명으로 처리됩니다. 누군가 위급한 상황에 있다고 생각된다면 즉시 현지 응급 서비스 기관에 연락하시기 바랍니다.")
        .lineLimit(5)
        .fontSystem(fontDesignSystem: .caption_KO_Regular)
        .foregroundColor(.LabelColor_Secondary)
        .padding(.bottom, 16)
      Divider().frame(width: UIScreen.width)
      if reportCategory == .post {
        ForEach(ContentReportReason.allCases, id: \.self) { reason in
          NavigationLink {
            ProfileReportCommentView(
              goReport: $goReport,
              selectedContentId: $selectedContentId,
              reportCategory: .post,
              reportReason: reason.numericValue,
              userId: userId)
          } label: {
            reportRow(text: reason.rawValue)
          }
        }
      } else {
        ForEach(UserReportReason.allCases, id: \.self) { reason in
          NavigationLink {
            if apiViewModel.memberFeed.isEmpty {
              ProfileReportCommentView(
                goReport: $goReport,
                selectedContentId: .constant(0),
                reportCategory: .user,
                reportReason: reason.numericValue,
                userId: userId)

            } else {
              ProfileReportContentSelectionView(
                selectedContentId: $selectedContentId,
                goReport: $goReport,
                userId: userId,
                reportCategory: .user,
                reportReason: reason.numericValue)
            }
          } label: {
            reportRow(text: reason.rawValue)
          }
        }
      }
      Spacer()
    }
    .padding(.horizontal, 16)
    .background(Color.reactiveBackground)
    .navigationBarBackButtonHidden()
    .navigationTitle(CommonWords().report)
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
    }
  }
}

extension ProfileReportReasonSelectionView {
  @ViewBuilder
  func reportRow(text: String) -> some View {
    HStack {
      Text(text)
        .fontSystem(fontDesignSystem: .subtitle2_KO)
        .foregroundColor(.LabelColor_Primary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .listRowSeparator(.hidden)
      Spacer()
      Image(systemName: "chevron.forward")
        .foregroundColor(.Disable_Placeholder)
    }
    .frame(height: 56)
  }
}
