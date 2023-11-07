//
//  ZoomFactorCombineViewModel.swift
//  Whistle
//
//  Created by ChoiYujin on 11/1/23.
//

import Combine
import Foundation

// MARK: - ZoomFactorCombineViewModel

open class ZoomFactorCombineViewModel: ObservableObject {
  static public let shared = ZoomFactorCombineViewModel()
  public var zoomSubject = CurrentValueSubject<CGFloat, Never>(1.0)

  private init() { }

  var zoomScale: CGFloat {
    get { zoomSubject.value }
    set { zoomSubject.send(newValue) }
  }
}
