//
//  Extension+Date.swift
//  Whistle
//
//  Created by ChoiYujin on 10/29/23.
//

import Foundation

extension Date {
  func toString() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.timeZone = TimeZone(identifier: "UTC")
    return dateFormatter.string(from: self)
  }
}
