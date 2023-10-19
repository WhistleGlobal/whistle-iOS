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
    let viewWidth = uiViewController.view.bounds.width
//    previewLayer.frame = uiViewController.view.bounds
    previewLayer.frame = CGRect(x: 0, y: -34, width: viewWidth, height: viewWidth * 16 / 9)
  }

  func dismantleUIViewController(_: UIViewController, coordinator _: ()) {
    previewLayer.removeFromSuperlayer()
  }
}
