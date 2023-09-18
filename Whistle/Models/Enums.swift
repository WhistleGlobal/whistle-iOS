//
//  Enums.swift
//  Whistle
//
//  Created by ChoiYujin on 9/18/23.
//

import Foundation

// MARK: - UserReportReason

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

// MARK: - PostReportReason

enum PostReportReason: String, CaseIterable {

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
