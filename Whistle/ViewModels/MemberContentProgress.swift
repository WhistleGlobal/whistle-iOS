//
//  MemberContentProgress.swift
//  Whistle
//
//  Created by 박상원 on 11/26/23.
//

import Combine
import Foundation
import SwiftUI

// MARK: - DownloadState

enum DownloadState {
  case notStarted, downloading, finished
}

// MARK: - MemberContentProgress

class MemberContentProgress {
  let downloadSubject = CurrentValueSubject<DownloadState, Never>(.notStarted)

  var downloadState: DownloadState {
    get { downloadSubject.value }
    set { downloadSubject.send(newValue) }
  }

  func changeDownloadState(state: DownloadState) {
    downloadState = state
  }

  func reset() {
    downloadState = .notStarted
  }
}
