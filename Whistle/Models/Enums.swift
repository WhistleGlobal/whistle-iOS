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
    case .none: 100
    case .cyberbullying: 101
    case .identityTheft: 102
    case .violentThreat: 103
    case .abuse: 104
    case .hateSpeech: 105
    case .spamAndFraud: 106
    case .privacyViolation: 107
    }
  }
}

// MARK: - ContentReportReason

enum ContentReportReason: String, CaseIterable {
  case hatredOrAbuse = "증오 또는 학대하는 콘텐츠"
  case harmfulBehavior = "유해하거나 위험한 행위"
  case spamOrConfusion = "스팸 또는 혼동을 야기하는 콘텐츠"
  case violentOrHatefulContent = "폭력적 또는 혐오스러운 콘텐츠"
  case sexualContent = "성적인 콘텐츠"
  case none = "해당 문제 없음"
  case copyrightInfringement = "저작권 침해 콘텐츠"

  var numericValue: Int {
    switch self {
    case .none: 200
    case .hatredOrAbuse: 201
    case .harmfulBehavior: 202
    case .spamOrConfusion: 203
    case .violentOrHatefulContent: 204
    case .sexualContent: 205
    case .copyrightInfringement: 206
    }
  }
}
