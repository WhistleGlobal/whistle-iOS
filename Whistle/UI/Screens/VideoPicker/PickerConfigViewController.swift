//
//  PickerConfigViewController.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/20.
//

import UIKit
import VideoPicker

// MARK: - PickerConfigViewController

final class PickerConfigViewController: UIViewController {
  var options = PickerOptionsInfo()

  var isFullScreen = true

  override func viewDidLoad() {
    super.viewDidLoad()
    setupNavigation()
    setUpButton()
//    setupView()
  }

  override func viewWillAppear(_: Bool) {
    // 테스트용 코드
    addButtonTapped()
    //
    parent?.navigationItem.title = "Picker"
    let title = Bundle.main.localizedString(forKey: "OpenPicker", value: nil, table: nil)
    parent?.navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: title,
      style: .done,
      target: self,
      action: #selector(openPickerTapped))
  }

  @objc
  private func addButtonTapped() {
    openPickerTapped()
  }

  private func setUpButton() {
    let addButton = UIButton(type: .system)
    addButton.setTitle("추가", for: .normal)
    addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)

    // 버튼 레이아웃 설정
    addButton.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(addButton)

    // Auto Layout을 사용하여 버튼 위치 설정
    addButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
    addButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50).isActive = true
  }

  private func setupNavigation() {
    navigationItem.title = "Picker"
    let title = Bundle.main.localizedString(forKey: "OpenPicker", value: nil, table: nil)
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: title,
      style: .done,
      target: self,
      action: #selector(openPickerTapped))
  }

  // MARK: - Target

  @objc
  public func openPickerTapped() {
    options.enableDebugLog = true
    let controller = ImagePickerController(options: options, delegate: self)
    controller.trackDelegate = self
    if #available(iOS 13.0, *) {
      // 모달 방식 설정
      controller.modalPresentationStyle = .automatic
    }
    present(controller, animated: true, completion: nil)
  }
}

// MARK: ImagePickerControllerDelegate

extension PickerConfigViewController: ImagePickerControllerDelegate {
  func imagePicker(_ picker: ImagePickerController, didFinishPicking result: PickerResult) {
    print(result.assets)
    let controller = PickerResultViewController()
    controller.assets = result.assets
    show(controller, sender: nil)
    picker.dismiss(animated: true, completion: nil)
  }
}

// MARK: ImageKitDataTrackDelegate

extension PickerConfigViewController: ImageKitDataTrackDelegate {
  func dataTrack(page: AnyImagePage, state: AnyImagePageState) {
    switch state {
    case .enter:
      print("[Data Track] ENTER Page: \(page.rawValue)")
    case .leave:
      print("[Data Track] LEAVE Page: \(page.rawValue)")
    }
  }

  func dataTrack(event: AnyImageEvent, userInfo: [AnyImageEventUserInfoKey: Any]) {
    print("[Data Track] EVENT: \(event.rawValue), userInfo: \(userInfo)")
  }
}

// MARK: - RowTypeRule

protocol RowTypeRule {
  var defaultValue: String { get }
}

extension PickerConfigViewController {
  // MARK: - Section

  enum Section: Int, CaseIterable {
    case config

    var title: String? {
      switch self {
      case .config:
        return "Options"
      }
    }

    var allRowCase: [RowTypeRule] {
      switch self {
      case .config:
        return ConfigRowType.allCases
      }
    }
  }

  // MARK: - Config

  enum ConfigRowType: Int, CaseIterable, RowTypeRule {
    case selectionTapAction

    var defaultValue: String {
      switch self {
      case .selectionTapAction:
        return "Preview"
      }
    }
  }

  // MARK: - Editor Config

  enum EditorConfigRowType: Int, CaseIterable, RowTypeRule {
    case saveEditedAsset

    var title: String {
      switch self {
      case .saveEditedAsset:
        return "SaveEditedAsset"
      }
    }

    var options: String {
      switch self {
      case .saveEditedAsset:
        return ".saveEditedAsset"
      }
    }

    var defaultValue: String {
      switch self {
      case .saveEditedAsset:
        return "true"
      }
    }
  }
}
