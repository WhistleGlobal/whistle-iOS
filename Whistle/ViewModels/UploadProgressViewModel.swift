//
//  UploadProgressViewModel.swift
//  Whistle
//
//  Created by 박상원 on 10/19/23.
//

import Combine
import Foundation
import SwiftUI

class UploadProgressViewModel {
  static let shared = UploadProgressViewModel()

  let thumbnailSubject = CurrentValueSubject<Image, Never>(Image("noVideo"))
  let isUploadingSubject = CurrentValueSubject<Bool, Never>(false)
  let progressSubject = CurrentValueSubject<Double, Never>(0.0)
  let responseSubject = CurrentValueSubject<Bool, Never>(false)

  var isUploading: Bool {
    get { isUploadingSubject.value }
    set { isUploadingSubject.send(newValue) }
  }

  var progress: Double {
    get { progressSubject.value }
    set { progressSubject.send(newValue) }
  }

  var error: Bool {
    get { isUploadingSubject.value }
    set { isUploadingSubject.send(newValue) }
  }

  var thumbnail: Image {
    get { thumbnailSubject.value }
    set { thumbnailSubject.send(newValue) }
  }

  private init() { }

  func uploadEnded() {
    isUploading = false
    error = false
    thumbnail = Image("noVideo")
    progress = 0.0
  }

  func uploadStarted() {
    isUploading = true
  }
}
