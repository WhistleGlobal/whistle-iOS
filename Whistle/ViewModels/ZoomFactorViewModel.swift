//
//  ZoomFactorViewModel.swift
//  Whistle
//
//  Created by ChoiYujin on 11/1/23.
//

import Combine
import Foundation

// MARK: - ZoomFactorViewModel

// TODO: - ViewModel 두 종류 생성
class ZoomFactorViewModel: ObservableObject {
  static let shared = ZoomFactorViewModel()
  @Published var zoomScale: CGFloat = 1.0

  private init() { }
}

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
