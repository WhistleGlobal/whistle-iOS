//
//  MainFeedReportReasonSelectionView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/21/23.
//

import SwiftUI

// MARK: - MainFeedReportReasonSelectionView

struct MainFeedReportReasonSelectionView: View {
  @Environment(\.dismiss) var dismiss
  @StateObject var apiViewModel = APIViewModel.shared

  @State var goComplete = false
  @Binding var goReport: Bool
  let contentId: Int
  let userId: Int

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        Divider().frame(width: UIScreen.width)
        Text("이 콘텐츠를 신고하는 이유는 무엇인가요?")
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
        ForEach(ContentReportReason.allCases, id: \.self) { reason in
          NavigationLink {
            MainFeedReportCommentView(
              goReport: $goReport,
              reportReason: reason.numericValue,
              contentId: contentId,
              uesrId: userId)

          } label: {
            reportRow(text: reason.rawValue)
          }
        }
        Spacer()
      }
      .padding(.horizontal, 16)
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
            Image(systemName: "xmark")
              .foregroundColor(.LabelColor_Primary)
          }
        }
      }
    }
    .tint(.black)
  }
}

extension MainFeedReportReasonSelectionView {
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
