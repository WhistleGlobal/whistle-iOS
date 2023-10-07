//
//  Preview.swift
//  Whistle
//
//  Created by Lee Juwon on 2023/09/21.

import AVFoundation
import SwiftUI

struct Preview: UIViewControllerRepresentable {
  let previewLayer: AVCaptureVideoPreviewLayer
  let gravity: AVLayerVideoGravity

  init(
    session: AVCaptureSession,
    gravity: AVLayerVideoGravity)
  {
    self.gravity = gravity
    previewLayer = AVCaptureVideoPreviewLayer(session: session)
    previewLayer.videoGravity = gravity
  }

  func makeUIViewController(context _: Context) -> UIViewController {
    let viewController = UIViewController()
    return viewController
  }

  func updateUIViewController(_ uiViewController: UIViewController, context _: Context) {
    previewLayer.videoGravity = gravity
    uiViewController.view.layer.addSublayer(previewLayer)

    previewLayer.frame = uiViewController.view.bounds
//    print("updated")
  }

  func dismantleUIViewController(_: UIViewController, coordinator _: ()) {
    previewLayer.removeFromSuperlayer()
  }
}
