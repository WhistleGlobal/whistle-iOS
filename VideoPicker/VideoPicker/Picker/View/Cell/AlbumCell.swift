//
//  AlbumCell.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/17.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

// MARK: - AlbumCell

final class AlbumCell: UITableViewCell {
  private lazy var posterImageView: UIImageView = {
    let view = UIImageView(frame: .zero)
    view.contentMode = .scaleAspectFill
    view.frame = CGRect(x: 0, y: 0, width: 64, height: 64)
    view.layer.cornerRadius = 8
    view.layer.masksToBounds = true
    return view
  }()

  private lazy var titleLabel: UILabel = {
    let view = UILabel(frame: .zero)
    view.font = UIFont.preferredFont(forTextStyle: .body)
    return view
  }()

  private lazy var subTitleLabel: UILabel = {
    let view = UILabel(frame: .zero)
    view.font = UIFont.preferredFont(forTextStyle: .body)
    return view
  }()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupView()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupView() {
    // Subviews
    contentView.addSubview(posterImageView)
    contentView.addSubview(titleLabel)
    contentView.addSubview(subTitleLabel)
    posterImageView.snp.makeConstraints { maker in
      maker.left.top.bottom.equalToSuperview()
      maker.width.equalTo(posterImageView.snp.height)
    }
    titleLabel.snp.makeConstraints { maker in
      maker.centerY.equalTo(contentView.snp.centerY)
      maker.left.equalTo(posterImageView.snp.right).offset(16)
    }
    subTitleLabel.snp.makeConstraints { maker in
      maker.centerY.equalTo(contentView.snp.centerY)
      maker.left.equalTo(titleLabel.snp.right).offset(8)
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
  }
}

extension AlbumCell {
  private func updateTheme(_ theme: PickerTheme) {
    tintColor = theme[color: .primary]
    backgroundColor = UIColor.clear

    titleLabel.textColor = theme[color: .whiteText]
    subTitleLabel.textColor = theme[color: .subText]

    theme.labelConfiguration[.albumCellTitle]?.configuration(titleLabel)
    theme.labelConfiguration[.albumCellSubTitle]?.configuration(subTitleLabel)
  }
}

extension AlbumCell {
  func setContent(_ album: Album, manager: PickerManager) {
    updateTheme(manager.options.theme)
    titleLabel.text = album.title
    subTitleLabel.text = "\(album.count)"
    manager.requestPhoto(for: album) { [weak self] result in
      guard let self else { return }
      switch result {
      case .success(let response):
        posterImageView.image = response.image
      case .failure(let error):
        _print(error)
      }
    }
  }
}
