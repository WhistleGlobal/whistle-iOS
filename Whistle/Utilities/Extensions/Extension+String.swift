//
//  Extension+String.swift
//  Whistle
//
//  Created by ChoiYujin on 10/29/23.
//

import Foundation

extension String {
  func toDate() -> Date? { // "yyyy-MM-dd HH:mm:ss"
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.timeZone = TimeZone(identifier: "UTC")
    if let date = dateFormatter.date(from: self) {
      return date
    } else {
      return nil
    }
  }
}
