//
//  ProfileReportTypeSelectionView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/9/23.
//

import SwiftUI

// MARK: - ProfileReportTypeSelectionView

struct ProfileReportTypeSelectionView: View {
  public enum ReportCategory {
    case post
    case user
  }

  @Environment(\.dismiss) var dismiss
  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject var alertViewModel = AlertViewModel.shared

  @State var reportType = 0
  @State var selectedContentId = 0
  @Binding var goReport: Bool
  let userId: Int

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        Divider().frame(width: UIScreen.width)
        Group {
          Text("무엇을 신고하려고 하시나요?")
            .fontSystem(fontDesignSystem: .subtitle2)
            .foregroundColor(.labelColorPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 16)
            .padding(.bottom, 4)
          Text("지식재산권 침해를 신고하는 경우를 제외하고 회원님의 신고는 익명으로 처리됩니다. 누군가 위급한 상황에 있다고 생각된다면 즉시 현지 응급 서비스 기관에 연락하시기 바랍니다.")
            .lineLimit(5)
            .fontSystem(fontDesignSystem: .caption_Regular)
            .foregroundColor(.labelColorSecondary)
            .padding(.bottom, 16)
        }
        .padding(.horizontal, 16)
        Divider().frame(width: UIScreen.width)
        NavigationLink {
          ProfileReportContentSelectionView(
            selectedContentId: $selectedContentId,
            goReport: $goReport,
            userId: userId,
            reportCategory: .post,
            reportReason: 0)
        } label: {
          reportRow(text: "특정 콘텐츠", isContentReport: true)
        }
        .disabled(apiViewModel.memberFeed.isEmpty)
        .padding(.horizontal, 16)
        Divider().frame(height: 0.5).padding(.leading, 16).foregroundColor(.labelColorDisablePlaceholder)
        NavigationLink {
          ProfileReportReasonSelectionView(
            goReport: $goReport,
            selectedContentId: $selectedContentId,
            userId: userId,
            reportCategory: .user)

        } label: {
          reportRow(text: "이 계정에 관한 문제", isContentReport: false)
        }
        .padding(.horizontal, 16)
        Divider().frame(height: 0.5).padding(.leading, 16).foregroundColor(.labelColorDisablePlaceholder)
        Spacer()
      }
      .background(Color.backgroundDefault)
      .navigationTitle(CommonWords().report)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button {
            dismiss()
          } label: {
            Image(systemName: "xmark")
              .foregroundColor(.labelColorPrimary)
          }
        }
      }
    }
    .overlay {
      if alertViewModel.onFullScreenCover {
        AlertPopup().ignoresSafeArea()
      }
    }
  }
}

extension ProfileReportTypeSelectionView {
  @ViewBuilder
  func reportRow(text: String, isContentReport: Bool) -> some View {
    HStack {
      Text(text)
        .fontSystem(fontDesignSystem: .subtitle2)
        .foregroundColor(apiViewModel.memberFeed.isEmpty && isContentReport ? .labelColorDisablePlaceholder : .labelColorPrimary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .listRowSeparator(.hidden)
      Spacer()
    }
    .frame(height: 56)
  }
}
