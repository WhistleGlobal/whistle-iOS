//
//  Preview.swift
//
//
//  Created by Young Bin on 2023/06/30.
//

import AVFoundation
import Foundation
import SwiftUI

struct Preview: UIViewControllerRepresentable {
  let session: AespaSession
  let gravity: AVLayerVideoGravity
  let previewLayer: AVCaptureVideoPreviewLayer

  init(
    of session: AespaSession,
    gravity: AVLayerVideoGravity)
  {
    self.gravity = gravity
    self.session = session
    previewLayer = session.previewLayer
  }

  func makeUIViewController(context _: Context) -> UIViewController {
    let viewController = UIViewController()
    viewController.view.backgroundColor = .clear

    return viewController
  }

  func updateUIViewController(_ uiViewController: UIViewController, context _: Context) {
    previewLayer.videoGravity = gravity
    uiViewController.view.layer.addSublayer(previewLayer)

    previewLayer.frame = uiViewController.view.bounds
  }

  func dismantleUIViewController(_: UIViewController, coordinator _: ()) {
    previewLayer.removeFromSuperlayer()
  }
}
