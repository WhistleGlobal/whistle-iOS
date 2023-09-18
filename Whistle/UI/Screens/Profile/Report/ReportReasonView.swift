//
//  ReportReasonView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/14/23.
//

import SwiftUI

// MARK: - ReportReasonView

struct ReportReasonView: View {

  public enum UserReportReason: String, CaseIterable {

    case cyberbullying = "권리 침해 또는 사이버 괴롭힘"
    case identityTheft = "명의 도용"
    case violentThreat = "폭력적 위협"
    case abuse = "학대"
    case hateSpeech = "보호 대상 집단에 대한 증오심 표현"
    case spamAndFraud = "스팸 및 사기"
    case privacyViolation = "사생활 침해"
    case none = "해당 문제 없음"

    var numericValue: Int {
      switch self {
      case .none: return 100
      case .cyberbullying: return 101
      case .identityTheft: return 102
      case .violentThreat: return 103
      case .abuse: return 104
      case .hateSpeech: return 105
      case .spamAndFraud: return 106
      case .privacyViolation: return 107
      }
    }
  }

  public enum PostReportReason: String, CaseIterable {

    case none = "해당 문제 없음"
    case hatredOrAbuse = "증오 또는 학대하는 콘텐츠"
    case harmfulBehavior = "유해하거나 위험한 행위"
    case spamOrConfusion = "스팸 또는 혼동을 야기하는 콘텐츠"
    case violentOrHatefulContent = "폭력적 또는 혐오스러운 콘텐츠"
    case sexualContent = "성적인 콘텐츠"

    var description: Int {
      switch self {
      case .none: return 200
      case .hatredOrAbuse: return 201
      case .harmfulBehavior: return 202
      case .spamOrConfusion: return 203
      case .violentOrHatefulContent: return 204
      case .sexualContent: return 205
      }
    }
  }

  @Environment(\.dismiss) var dismiss
  @EnvironmentObject var apiViewModel: APIViewModel
  @Binding var goReport: Bool
  @State var showAlert = false
  @State var goComplete = false
  let userId: Int
  let reportCategory: ReportUserView.ReportCategory

  var body: some View {
    VStack(spacing: 0) {
      Divider().frame(width: UIScreen.width)
      Text("이 계정을 신고하는 이유는 무엇인가요?")
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
          Button {
            showAlert = true
          } label: {
            reportRow(text: reason.rawValue)
          }
        }
      } else {
        ForEach(UserReportReason.allCases, id: \.self) { reason in
          NavigationLink {
            ReportPostView(goReport: $goReport, userId: userId, reportCategory: .user)
              .environmentObject(apiViewModel)
          } label: {
            reportRow(text: reason.rawValue)
          }
        }
      }
      Spacer()
    }
    .padding(.horizontal, 16)
    .navigationBarBackButtonHidden()
    .overlay {
      if showAlert {
        ReportAlert {
          showAlert = false
        } reportAction: {
          goComplete = true
        }
      }
    }
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
