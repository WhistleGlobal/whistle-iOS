//
//  Extension+UITableViewCell.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/20.
//
import UIKit

extension UITableViewCell {
  static var reuseIdentifier: String {
    String(describing: Self.self)
  }
}
