//
//  EnableCell.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/20.
//

import UIKit

final class EnableCell: UITableViewCell {
  private(set) lazy var titleLabel: UILabel = {
    let view = UILabel(frame: .zero)
    view.font = UIFont.systemFont(ofSize: 15, weight: .regular)
    view.textAlignment = .left
    return view
  }()

  private(set) lazy var enableSwitch: UISwitch = {
    let view = UISwitch(frame: .zero)
    return view
  }()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupView()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupView()
  }

  private func setupView() {
    contentView.addSubview(titleLabel)
    contentView.addSubview(enableSwitch)
    titleLabel.snp.makeConstraints { maker in
      maker.centerY.equalToSuperview()
      maker.leading.equalToSuperview().offset(20)
    }
    enableSwitch.snp.makeConstraints { maker in
      maker.centerY.equalToSuperview()
      maker.trailing.equalToSuperview().offset(-20)
    }
  }
}
