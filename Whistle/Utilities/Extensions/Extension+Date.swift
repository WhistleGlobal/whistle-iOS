//
//  Extension+Date.swift
//  Whistle
//
//  Created by 박상원 on 10/30/23.
//

import Foundation

extension Date {
  func toString() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.timeZone = TimeZone(identifier: "UTC")
    return dateFormatter.string(from: self)
  }

  func koreaTimezone() -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
    guard let date = dateFormatter.date(from: Date().toString()) else { return Date() }
    return date
  }
}


extension Date {
  static func timeAgoSinceDate(_ date: Date) -> String {
    let calendar = Calendar.current
    let now = Date()

    let components = calendar.dateComponents([.year, .month, .weekOfYear, .day, .hour], from: date, to: now)

    if let year = components.year, year > 0 {
      return String(format: NSLocalizedString("%d년", comment: ""), year)
    }

    if let month = components.month, month > 0 {
      return String(format: NSLocalizedString("%d달", comment: ""), month)
    }

    if let week = components.weekOfYear, week > 0 {
      return String(format: NSLocalizedString("%d주", comment: ""), week)
    }

    if let day = components.day, day > 0 {
      return String(format: NSLocalizedString("%d일", comment: ""), day)
    }

    if let hour = components.hour, hour > 0 {
      return String(format: NSLocalizedString("%d시간", comment: ""), hour)
    }
    return NSLocalizedString("Just now", comment: "")
  }
}
