//
//  PickerPreviewCell.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/20.
//

import UIKit

final class PickerPreviewCell: UICollectionViewCell {

  private(set) lazy var titleLabel: UILabel = {
    let view = UILabel(frame: .zero)
    if #available(iOS 13.0, *) {
      view.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)
      view.textColor = .label
    } else {
      view.backgroundColor = UIColor.white.withAlphaComponent(0.9)
      view.textColor = .black
    }
    view.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
    return view
  }()

  private(set) lazy var imageView: UIImageView = {
    let view = UIImageView(frame: .zero)
    view.contentMode = .scaleAspectFill
    view.layer.masksToBounds = true
    return view
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupView() {
    contentView.addSubview(imageView)
    imageView.snp.makeConstraints { maker in
      maker.edges.equalToSuperview()
    }
  }
}
