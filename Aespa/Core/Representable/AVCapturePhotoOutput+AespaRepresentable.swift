//
//  AVCapturePhotoOutput+AespaRepresentable.swift
//
//
//  Created by Young Bin on 2023/06/18.
//

import AVFoundation
import Foundation

// MARK: - AespaPhotoOutputRepresentable

protocol AespaPhotoOutputRepresentable {
  func capturePhoto(with: AVCapturePhotoSettings, delegate: AVCapturePhotoCaptureDelegate)
  func getConnection(with mediaType: AVMediaType) -> AespaCaptureConnectionRepresentable?
}

// MARK: - AVCapturePhotoOutput + AespaPhotoOutputRepresentable

extension AVCapturePhotoOutput: AespaPhotoOutputRepresentable {
  func getConnection(with mediaType: AVMediaType) -> AespaCaptureConnectionRepresentable? {
    connection(with: mediaType)
  }
}
