//
//  AlbumPickerViewController.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/16.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

private let rowHeight: CGFloat = 80

// MARK: - AlbumPickerViewControllerDelegate

protocol AlbumPickerViewControllerDelegate: AnyObject {
  func albumPicker(_ picker: AlbumPickerViewController, didSelected album: Album)
  func albumPickerWillDisappear(_ picker: AlbumPickerViewController)
}

// MARK: - AlbumPickerViewController

final class AlbumPickerViewController: AnyImageViewController {
  weak var delegate: AlbumPickerViewControllerDelegate?
  var album: Album?
  var albums = [Album]()

  private lazy var tableView: UITableView = {
    let view = UITableView(frame: .zero, style: .plain)
    view.registerCell(AlbumCell.self)
    view.separatorStyle = .none
    view.dataSource = self
    view.delegate = self
    view.backgroundColor = .clear
    return view
  }()

  private lazy var emptyAlbumView: UIView = {
    let view = UIView()
    let imageView = UIImageView()
    let imageConfig = UIImage.SymbolConfiguration(pointSize: 48)
    imageView.image = UIImage(systemName: "photo.fill", withConfiguration: imageConfig)
    imageView.tintColor = .white

    let label = UILabel()
    label.text = "사용할 수 있는 앨범이 없습니다."
    label.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 14)
    label.textColor = .white

    view.addSubview(imageView)
    view.addSubview(label)

    // 이미지와 레이블을 위아래로 배치하기 위한 제약 조건 설정
    imageView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
    }

    label.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(imageView.snp.bottom).offset(26)
    }

    return view
  }()

  private func setupEmptyAlbumView() {
    // emptyAlbumView를 슈퍼뷰의 중앙에 위치하도록 제약 조건 설정
    view.addSubview(emptyAlbumView)

    emptyAlbumView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview().offset(-50)
    }

//    emptyAlbumView.isHidden = true
  }

  private func updateEmptyAlbumLabel() {
    // 앨범이 비어있는지 여부에 따라 emptyAlbumView의 표시 여부를 업데이트
    emptyAlbumView.isHidden = !albums.isEmpty
  }

  let manager: PickerManager

  init(manager: PickerManager) {
    self.manager = manager
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    removeNotifications()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    addNotifications()
    updatePreferredContentSize(with: traitCollection)
    setupView()
    if albums.isEmpty {
      setupEmptyAlbumView()
    }
    update(options: manager.options)
    edgesForExtendedLayout = .all
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    delegate?.albumPickerWillDisappear(self)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    scrollToCurrentAlbum()
  }

  override func willTransition(
    to newCollection: UITraitCollection,
    with coordinator: UIViewControllerTransitionCoordinator)
  {
    super.willTransition(to: newCollection, with: coordinator)
    updatePreferredContentSize(with: newCollection)
  }

  func reloadData() {
    tableView.reloadData()
  }

  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    [.portrait]
  }

  override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
    .portrait
  }
}

// MARK: - Target

extension AlbumPickerViewController {
  @objc
  private func cancelButtonTapped(_: UIBarButtonItem) {
    dismiss(animated: true, completion: nil)
  }

  @objc
  private func orientationDidChangeNotification(_: Notification) {
    // TODO: Fix orientation change
    if UIDevice.current.userInterfaceIdiom == .pad {
      dismiss(animated: true, completion: nil)
    }
  }
}

// MARK: - Private

extension AlbumPickerViewController {
  private func addNotifications() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(orientationDidChangeNotification(_:)),
      name: UIDevice.orientationDidChangeNotification,
      object: nil)
  }

  private func removeNotifications() {
    NotificationCenter.default.removeObserver(self)
  }

  private func setupView() {
    view.addSubview(tableView)
    tableView.snp.makeConstraints { maker in
      maker.edges.equalTo(view.snp.edges)
    }
  }

  private func scrollToCurrentAlbum() {
    if let album, let index = albums.firstIndex(of: album) {
      let indexPath = IndexPath(row: index, section: 0)
      tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
      tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: rowHeight * 1.5, right: 0)
    }
  }

  private func updatePreferredContentSize(with _: UITraitCollection) {
    let screenSize = ScreenHelper.mainBounds.size
    _ = screenSize.height - rowHeight * 2
    let preferredMaxHeight = screenSize.height - rowHeight * 2
    let presentingViewController = (presentingViewController as? ImagePickerController)?.topViewController
    let preferredWidth = presentingViewController?.view.bounds.size.width ?? screenSize.width
    if albums.isEmpty {
      preferredContentSize = CGSize(width: preferredWidth, height: preferredMaxHeight)
    } else {
      _ = CGFloat(albums.count) * rowHeight
      preferredContentSize = CGSize(width: preferredWidth, height: screenSize.height)
    }
  }
}

// MARK: PickerOptionsConfigurable

extension AlbumPickerViewController: PickerOptionsConfigurable {
  func update(options: PickerOptionsInfo) {
    tableView.backgroundColor = UIColor.clear
    updateChildrenConfigurable(options: options)
    tableView.backgroundView = UIVisualEffectView.glassView()
  }
}

// MARK: UITableViewDataSource

extension AlbumPickerViewController: UITableViewDataSource {
  func numberOfSections(in _: UITableView) -> Int {
    1
  }

  func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
    albums.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(AlbumCell.self, for: indexPath)
    let album = albums[indexPath.row]
    cell.setContent(album, manager: manager)
    // 선택된 앨범을 앨범 목록에서 체크마크로 보여줍니다.
//    cell.accessoryType = self.album == album ? .checkmark : .none
    return cell
  }
}

// MARK: UITableViewDelegate

extension AlbumPickerViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let album = albums[indexPath.row]
    delegate?.albumPicker(self, didSelected: album)
    dismiss(animated: true, completion: nil)
    tableView.deselectRow(at: indexPath, animated: true)
  }

  func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
    rowHeight
  }
}
