//
//  ReportReasonView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/14/23.
//

import SwiftUI

// MARK: - ReportReasonView

struct ReportReasonView: View {

  enum UserReportReason: String, CaseIterable {

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


  @Environment(\.dismiss) var dismiss

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
      ForEach(UserReportReason.allCases, id: \.self) { reason in
        Button {
          log("reason \(reason.numericValue)")
        } label: {
          reportRow(text: reason.rawValue)
        }
      }
      Spacer()
    }
    .padding(.horizontal, 16)
    .navigationBarBackButtonHidden()
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

#Preview {
  ReportReasonView()
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
