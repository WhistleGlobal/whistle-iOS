//
//  Extension+NSObject.swift
//  Whistle
//
//  Created by ChoiYujin on 8/29/23.
//

import Foundation

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
