//
//  WhistleLogger.swift
//  VideoPicker
//
//  Created by ChoiYujin on 10/25/23.
//

import Foundation
import OSLog

enum WhistleLogger {
  static let logger = Logger(subsystem: "\(String(describing: Bundle.main.bundleIdentifier))", category: "\(#file)")
}
