//
//  ReportReasonView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/14/23.
//

import SwiftUI

// MARK: - ReportReasonView

struct ReportReasonView: View {
  @Environment(\.dismiss) var dismiss
  @StateObject var apiViewModel = APIViewModel.shared
  @Binding var goReport: Bool
  @Binding var selectedContentId: Int
  @State var goComplete = false
  let userId: Int
  let reportCategory: ReportUserView.ReportCategory

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
        ForEach(PostReportReason.allCases, id: \.self) { reason in
          NavigationLink {
            ReportDetailView(
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
            if apiViewModel.userPostFeed.isEmpty {
              ReportDetailView(
                goReport: $goReport,
                selectedContentId: .constant(0),
                reportCategory: .user,
                reportReason: reason.numericValue,
                userId: userId)

            } else {
              ReportPostView(
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
    .navigationBarBackButtonHidden()
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
      ToolbarItem(placement: .principal) {
        Text("신고")
          .fontSystem(fontDesignSystem: .subtitle2_KO)
      }
    }
  }
}

extension ReportReasonView {
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
