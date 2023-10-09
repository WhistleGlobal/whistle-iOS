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
    update(options: manager.options)
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
    }
  }

  private func updatePreferredContentSize(with _: UITraitCollection) {
    let screenSize = ScreenHelper.mainBounds.size
    let preferredMinHeight = screenSize.height - rowHeight * 2
    let preferredMaxHeight = screenSize.height - rowHeight * 2
    let presentingViewController = (presentingViewController as? ImagePickerController)?.topViewController
    let preferredWidth = presentingViewController?.view.bounds.size.width ?? screenSize.width
    if albums.isEmpty {
      preferredContentSize = CGSize(width: preferredWidth, height: preferredMaxHeight)
    } else {
      let height = CGFloat(albums.count) * rowHeight
      let preferredHeight = max(preferredMinHeight, min(height, preferredMaxHeight))
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
    albums.count + 2
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.row < albums.count {
      let cell = tableView.dequeueReusableCell(AlbumCell.self, for: indexPath)
      let album = albums[indexPath.row]
      cell.setContent(album, manager: manager)
      cell.accessoryType = self.album == album ? .checkmark : .none
      return cell
    } else {
      // 빈 row를 위한 셀을 생성하거나 사용할 셀을 만듭니다.
      // 예를 들어, 기본 UITableViewCell을 사용하거나 커스텀 셀을 따로 만들 수 있습니다.
      let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
      cell.textLabel?.text = "" // 빈 텍스트로 설정하거나 원하는 내용을 추가합니다.
      cell.backgroundColor = .clear
      return cell
    }
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
