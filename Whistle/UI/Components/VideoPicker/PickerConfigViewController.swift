//
//  PickerConfigViewController.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/20.
//

import Combine
import SwiftUI
import UIKit
import VideoPicker

// MARK: - PickerConfigViewController

final class PickerConfigViewController: UIViewController {
  var options = PickerOptionsInfo()

  var isFullScreen = true
  var isImagePickerClosed: PassthroughSubject<Bool, Never>?
  var cancellables = Set<AnyCancellable>()
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func viewWillAppear(_: Bool) {
    openPickerTapped()
    view.backgroundColor = UIColor.clear
  }

  // MARK: - Target

  @objc
  public func openPickerTapped() {
    options.enableDebugLog = true
    let controller = ImagePickerController(
      options: options,
      delegate: self,
      imagePickerClosedSubject: isImagePickerClosed)
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
  /// Picker에서 선택된 asset을 MainEditorview로 전달해 줍니다.
  func imagePicker(_ picker: ImagePickerController, didFinishPicking result: PickerResult) {
    var videoURL: URL?
    result.assets[0].phAsset.loadURL { result in
      switch result {
      case .success(let url):
        videoURL = url
        DispatchQueue.main.async {
          let editorView = VideoEditorView(selectedVideoURL: videoURL)

          if let navigationController = self.navigationController {
            navigationController.pushViewController(UIHostingController(rootView: editorView), animated: true)
            picker.dismiss(animated: true, completion: nil)
          }
        }
      case .failure(let error):
        print("Error: \(error)")
      }
    }
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
