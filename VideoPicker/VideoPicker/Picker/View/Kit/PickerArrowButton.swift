//
//  PickerArrowButton.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/9/18.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

// MARK: - PickerArrowButton

final class PickerArrowButton: UIControl {
  private lazy var label: UILabel = {
    let view = UILabel(frame: .zero)
    view.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
    view.textColor = .white
    return view
  }()

  private lazy var imageView: UIImageView = {
    let view = UIImageView(frame: .zero)
    return view
  }()

  private var preferredStyle: UserInterfaceStyle = .auto

  override var isSelected: Bool {
    didSet {
      UIView.animate(withDuration: 0.2) {
        self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(self.isSelected ? Double.pi : 0))
        self.layoutIfNeeded()
      }
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
    addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
    isAccessibilityElement = true
    accessibilityTraits = .button
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
  }

  private func setupView() {
    addSubview(label)
    addSubview(imageView)

    label.snp.makeConstraints { maker in
      maker.top.bottom.equalToSuperview()
      maker.left.equalToSuperview().offset(12)
    }
    imageView.snp.makeConstraints { maker in
      maker.left.equalTo(label.snp.right).offset(8)
      maker.right.equalToSuperview().offset(-6)
      maker.width.height.equalTo(20)
      maker.centerY.equalToSuperview()
    }
  }

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    if #available(iOS 13.0, *) {
      guard preferredStyle == .auto else { return }
      guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
    }
  }
}

// MARK: - Function

extension PickerArrowButton {
  func setTitle(_ title: String) {
    if isSelected {
      isSelected = false
    }
    UIView.animate(withDuration: 0.2) {
      self.label.text = title
      self.label.textColor = .white
      self.layoutIfNeeded()
    }
  }
}

// MARK: - Target

extension PickerArrowButton {
  @objc
  private func buttonTapped(_: UIButton) {
    isSelected.toggle()
  }
}

// MARK: PickerOptionsConfigurable

extension PickerArrowButton: PickerOptionsConfigurable {
  func update(options: PickerOptionsInfo) {
    preferredStyle = options.theme.style
    label.textColor = options.theme[color: .whiteText]
    imageView.image = options.theme[icon: .albumArrow]

    options.theme.labelConfiguration[.albumTitle]?.configuration(label)
  }
}
