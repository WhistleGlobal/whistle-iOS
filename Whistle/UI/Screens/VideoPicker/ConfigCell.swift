//
//  ConfigCell..swift
//  Whistle
//
//  Created by 박상원 on 2023/09/20.
//

import UIKit

final class ConfigCell: UITableViewCell {
  private(set) lazy var contentLabel: UILabel = {
    let view = UILabel(frame: .zero)
    view.font = UIFont.systemFont(ofSize: 16, weight: .regular)
    view.numberOfLines = 2
    view.adjustsFontSizeToFitWidth = true
    if #available(iOS 13.0, *) {
      view.textColor = UIColor.secondaryLabel
    } else {
      view.textColor = UIColor.gray
    }
    view.textAlignment = .right
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
    let layoutGuide = UILayoutGuide()
    contentView.addLayoutGuide(layoutGuide)
    layoutGuide.snp.makeConstraints { maker in
      maker.centerY.equalToSuperview()
      maker.left.equalToSuperview().offset(16)
    }
  }
}
