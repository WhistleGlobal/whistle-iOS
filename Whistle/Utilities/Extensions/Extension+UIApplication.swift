//
//  Extension+UIApplication.swift
//  Whistle
//
//  Created by 박상원 on 11/5/23.
//

import Foundation
import SwiftUI

extension UIApplication {
  func endEditing() {
    sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  }
}
