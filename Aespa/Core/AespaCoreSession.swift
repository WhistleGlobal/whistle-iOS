//
//  AespaCoreSession.swift
//
//
//  Created by 이영빈 on 2023/06/02.
//

import AVFoundation
import Combine
import Foundation
import UIKit

class AespaCoreSession: AVCaptureSession {
  var option: AespaOption
  private var workQueue = OperationQueue()

  init(option: AespaOption) {
    self.option = option

    workQueue.qualityOfService = .background
    workQueue.maxConcurrentOperationCount = 1
    workQueue.isSuspended = true
  }

  func run(_ tuner: some AespaSessionTuning, _ onComplete: @escaping CompletionHandler) {
    workQueue.addOperation {
      do {
        if tuner.needTransaction { self.beginConfiguration() }
        defer {
          if tuner.needTransaction { self.commitConfiguration() }
          onComplete(.success(()))
        }

        try tuner.tune(self)
      } catch {
        AespaLogger.log(error: error, message: "in \(tuner)")
        onComplete(.failure(error))
      }
    }
  }

  func run(_ tuner: some AespaDeviceTuning, _ onComplete: @escaping CompletionHandler) {
    workQueue.addOperation {
      do {
        guard let device = self.videoDeviceInput?.device else {
          throw AespaError.device(reason: .invalid)
        }

        if tuner.needLock { try device.lockForConfiguration() }
        defer {
          if tuner.needLock { device.unlockForConfiguration() }
          onComplete(.success(()))
        }

        try tuner.tune(device)
      } catch {
        AespaLogger.log(error: error, message: "in \(tuner)")
        onComplete(.failure(error))
      }
    }
  }

  func run(_ tuner: some AespaConnectionTuning, _ onComplete: @escaping CompletionHandler) {
    workQueue.addOperation {
      do {
        guard let connection = self.connections.first else {
          throw AespaError.session(reason: .cannotFindConnection)
        }

        try tuner.tune(connection)
        onComplete(.success(()))
      } catch {
        AespaLogger.log(error: error, message: "in \(tuner)")
        onComplete(.failure(error))
      }
    }
  }

  func run(_ processor: some AespaMovieFileOutputProcessing, _ onComplete: @escaping CompletionHandler) {
    workQueue.addOperation {
      do {
        guard let output = self.movieFileOutput else {
          throw AespaError.session(reason: .cannotFindConnection)
        }

        try processor.process(output)
        onComplete(.success(()))
      } catch {
        AespaLogger.log(error: error, message: "in \(processor)")
        onComplete(.failure(error))
      }
    }
  }

  func start() throws {
    let session = self

    guard session.isRunning == false else { return }

    try session.addMovieInput()
    try session.addMovieFileOutput()
    try session.addCapturePhotoOutput()
    session.startRunning()

    workQueue.isSuspended = false
    AespaLogger.log(message: "Session is configured successfully")
  }
}
