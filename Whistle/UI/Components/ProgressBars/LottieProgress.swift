//
//  LottieProgress.swift
//  Whistle
//
//  Created by 박상원 on 11/7/23.
//

import Lottie
import SwiftUI
import UIKit

// MARK: - LottieProgress

struct LottieProgress: UIViewRepresentable {
  func makeUIView(context _: Context) -> LoadingView {
    let view = LoadingView()

    return view
  }

  func updateUIView(_: UIViewType, context _: Context) { }
}

// MARK: - LoadingView

public final class LoadingView: UIControl {
  private var text = "Loading..."
  var timer: Timer?
  private var dotsCount = 0
  private let maxDots = 3

  public init(text: String = "Loading") {
    self.text = text
    let frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    super.init(frame: frame)
    setupView()
  }

  required init?(coder: NSCoder) {
    text = "Loading"
    super.init(coder: coder)
    setupView()
  }

  public override func removeFromSuperview() {
    timer?.invalidate()
  }

  deinit {
    timer?.invalidate()
  }

  lazy var backgroundGlassView: UIVisualEffectView = {
    let view = UIVisualEffectView.glassView()
    view.layer.cornerRadius = 12
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

  private lazy var titleLabel: UILabel = {
    timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateDots), userInfo: nil, repeats: true)
    let view = UILabel()
    view.textAlignment = .left
    view.text = text
    view.textColor = .white
    view.numberOfLines = 1
    view.lineBreakMode = .byTruncatingTail
    view.font = .systemFont(ofSize: 16)
    view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    view.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

    return view
  }()
}

extension LoadingView {
  @objc
  public func updateDots() {
    if dotsCount < maxDots {
      dotsCount += 1
    } else {
      dotsCount = 0
    }
    let dots = String(repeating: ".", count: dotsCount)
    titleLabel.text = "Loading\(dots)"
  }

  private func setupView() {
    addSubview(backgroundGlassView)
    addSubview(indicator)
    addSubview(titleLabel)

    let tap = UITapGestureRecognizer(target: self, action: #selector(tapLoadingView))
    addGestureRecognizer(tap)

    backgroundGlassView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.equalTo(140)
      make.height.equalTo(140)
    }

    indicator.snp.makeConstraints { make in
      make.top.equalTo(backgroundGlassView.snp.top).offset(20)
      make.centerX.equalTo(backgroundGlassView)
      make.width.equalTo(70)
      make.height.equalTo(70)
    }

    titleLabel.snp.makeConstraints { make in
      make.top.equalTo(indicator.snp.bottom).offset(10)
      make.leading.equalTo(backgroundGlassView.snp.leading).offset(38)
      make.height.equalTo(20)
    }

    setNeedsLayout()
  }

  @objc
  private func tapLoadingView() {
    debugPrint(#function)
  }
}
