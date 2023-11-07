//
//  LoadingView.swift
//  AnyImageKit
//
//  Created by Ray Jiang on 2022/11/10.
//  Copyright © 2022 AnyImageKit.org. All rights reserved.
//

import Lottie
import UIKit

// MARK: - LoadingView

public final class LoadingView: UIControl {
  private lazy var blackView: UIView = {
    let view = UIView(frame: .zero)
    view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    view.layer.cornerRadius = 8
    view.clipsToBounds = true
    return view
  }()

  private lazy var indicator: UIStackView = {
    let view = UIStackView()
    let animationView = LottieAnimationView()
    let animation = LottieAnimation.named("ProgressLottie")
    animationView.animation = animation
    animationView.contentMode = .scaleAspectFit
    animationView.loopMode = .loop
    animationView.play()
    animationView.backgroundBehavior = .pauseAndRestore

    animationView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(animationView)

    NSLayoutConstraint.activate([
      animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
      animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
    ])

    return view
  }()

  private lazy var stackView: UIStackView = {
    let view = UIStackView(arrangedSubviews: [indicator])
    view.axis = .vertical
    view.distribution = .fill
    view.alignment = .center
    view.spacing = 10
    return view
  }()

  private let text: String

  public init( /* frame: CGRect, */ text: String = "") {
    self.text = text
    let frame = CGRect(x: 0, y: 0, width: 140, height: 140)
    super.init(frame: frame)
    setupView()
  }

  required init?(coder: NSCoder) {
    text = ""
    super.init(coder: coder)
    setupView()
  }
}

extension LoadingView {
  private func setupView() {
    addSubview(blackView)
    addSubview(stackView)

    let tap = UITapGestureRecognizer(target: self, action: #selector(tapLoadingView))
    addGestureRecognizer(tap)

    blackView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      if text.isEmpty {
        make.edges.equalTo(stackView).inset(-20)
      } else {
        make.top.bottom.equalTo(stackView).inset(-15)
        make.left.right.equalTo(stackView).inset(-15)
      }
    }
    stackView.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }

  @objc
  private func tapLoadingView() {
    debugPrint(#function)
  }
}
