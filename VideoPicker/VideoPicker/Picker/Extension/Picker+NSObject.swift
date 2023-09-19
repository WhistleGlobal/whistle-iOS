//
//  Picker+NSObject.swift
//  VideoPicker
//
//  Created by 박상원 on 2023/09/21.
//

import Foundation
import UIKit

extension NSObject {
  var values: [String: Any]? {
    get {
      value(forKeyPath: "requestedValues") as? [String: Any]
    }
    set {
      setValue(newValue, forKeyPath: "requestedValues")
    }
  }

  func value(key: String, filter: String) -> NSObject? {
    (value(forKey: key) as? [NSObject])?.first(where: { obj in
      obj.value(forKeyPath: "filterType") as? String == filter
    })
  }
}
