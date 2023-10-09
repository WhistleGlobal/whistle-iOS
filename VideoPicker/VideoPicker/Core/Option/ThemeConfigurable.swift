//
//  ThemeConfigurable.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2021/11/9.
//  Copyright © 2021-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

public typealias ThemeConfigurable
  = ThemeButtonConfigurable
  & ThemeColorConfigurable
  & ThemeIconConfigurable
  & ThemeLabelConfigurable
  & ThemeStringConfigurable

// MARK: - ThemeColorConfigurable

public protocol ThemeColorConfigurable {

  associatedtype ColorKey: Hashable

  subscript(color _: ColorKey) -> UIColor { get set }
}

// MARK: - ThemeIconConfigurable

public protocol ThemeIconConfigurable {

  associatedtype IconKey: Hashable

  subscript(icon _: IconKey) -> UIImage? { get set }
}

// MARK: - ThemeStringConfigurable

public protocol ThemeStringConfigurable {

  subscript(string _: StringConfigKey) -> String { get set }
}

// MARK: - ThemeLabelConfigurable

public protocol ThemeLabelConfigurable {

  associatedtype LabelKey: Hashable

  func configurationLabel(for key: LabelKey, configuration: @escaping ((UILabel) -> Void))
}

// MARK: - ThemeButtonConfigurable

public protocol ThemeButtonConfigurable {

  associatedtype ButtonKey: Hashable

  func configurationButton(for key: ButtonKey, configuration: @escaping ((UIButton) -> Void))
}
