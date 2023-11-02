//
//  ZoomFactorViewModel.swift
//  Whistle
//
//  Created by ChoiYujin on 11/1/23.
//

import Combine
import Foundation

// MARK: - ZoomFactorCombineViewModel

class ZoomFactorCombineViewModel: ObservableObject {
  static let shared = ZoomFactorCombineViewModel()
  let zoomSubject = CurrentValueSubject<CGFloat, Never>(1.0)

  private init() { }

  var zoomScale: CGFloat {
    get { zoomSubject.value }
    set { zoomSubject.send(newValue) }
  }
}
