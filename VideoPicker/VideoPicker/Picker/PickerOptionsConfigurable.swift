//
//  PickerOptionsConfigurable.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/4/4.
//  Copyright © 2021-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

// MARK: - PickerOptionsConfigurable

public protocol PickerOptionsConfigurable {

  var childrenConfigurable: [PickerOptionsConfigurable] { get }
  func update(options: PickerOptionsInfo)
  func updateChildrenConfigurable(options: PickerOptionsInfo)
}

extension PickerOptionsConfigurable {

  var childrenConfigurable: [PickerOptionsConfigurable] {
    []
  }

  func update(options: PickerOptionsInfo) {
    updateChildrenConfigurable(options: options)
  }

  func updateChildrenConfigurable(options: PickerOptionsInfo) {
    for child in childrenConfigurable {
      child.update(options: options)
    }
  }
}

extension PickerOptionsConfigurable where Self: UIViewController {

  var childrenConfigurable: [PickerOptionsConfigurable] {
    preferredChildrenConfigurable
  }

  var preferredChildrenConfigurable: [PickerOptionsConfigurable] {
    view.subviews.compactMap { $0 as? PickerOptionsConfigurable }
  }
}

extension PickerOptionsConfigurable where Self: UIView {

  var childrenConfigurable: [PickerOptionsConfigurable] {
    preferredChildrenConfigurable
  }

  var preferredChildrenConfigurable: [PickerOptionsConfigurable] {
    subviews.compactMap { $0 as? PickerOptionsConfigurable }
  }
}

extension PickerOptionsConfigurable where Self: UICollectionViewCell {

  var childrenConfigurable: [PickerOptionsConfigurable] {
    preferredChildrenConfigurable
  }

  var preferredChildrenConfigurable: [PickerOptionsConfigurable] {
    contentView.subviews.compactMap { $0 as? PickerOptionsConfigurable }
  }
}

extension PickerOptionsConfigurable where Self: UITableViewCell {

  var childrenConfigurable: [PickerOptionsConfigurable] {
    preferredChildrenConfigurable
  }

  var preferredChildrenConfigurable: [PickerOptionsConfigurable] {
    contentView.subviews.compactMap { $0 as? PickerOptionsConfigurable }
  }
}
