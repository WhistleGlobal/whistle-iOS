//
//  AespaCoreRecorder.swift
//
//
//  Created by 이영빈 on 2023/06/02.
//

import AVFoundation
import Combine
import Foundation

// MARK: - AespaCoreRecorder

/// Start, stop recording and responsible for notifying the result of recording
class AespaCoreRecorder: NSObject {
  private let core: AespaCoreSession

  /// Notify the end of recording
  private let fileIOResultSubject = PassthroughSubject<Result<URL, Error>, Never>()
  private var fileIOResultSubsciption: Cancellable?

  init(core: AespaCoreSession) {
    self.core = core
  }

  func run(processor: some AespaMovieFileOutputProcessing, _ onComplete: @escaping CompletionHandler) {
    guard let output = core.movieFileOutput else {
      onComplete(.failure(AespaError.session(reason: .cannotFindConnection)))
      return
    }

    do {
      try processor.process(output)
      onComplete(.success(()))
    } catch {
      onComplete(.failure(error))
    }
  }
}

extension AespaCoreRecorder {
  func startRecording(in filePath: URL, _ onComplete: @escaping CompletionHandler) {
    run(processor: StartRecordProcessor(filePath: filePath, delegate: self), onComplete)
  }

  func stopRecording() async throws -> URL {
    run(processor: FinishRecordProcessor()) { _ in }

    return try await withCheckedThrowingContinuation { continuation in
      fileIOResultSubsciption = fileIOResultSubject.sink { _ in
        // Do nothing on completion; we're only interested in values.
      } receiveValue: { result in
        switch result {
        case .success(let url):
          continuation.resume(returning: url)
        case .failure(let error):
          continuation.resume(throwing: error)
        }
      }
    }
  }
}

// MARK: AVCaptureFileOutputRecordingDelegate

extension AespaCoreRecorder: AVCaptureFileOutputRecordingDelegate {
  func fileOutput(
    _: AVCaptureFileOutput,
    didStartRecordingTo _: URL,
    from _: [AVCaptureConnection])
  {
    AespaLogger.log(message: "Recording started")
  }

  func fileOutput(
    _: AVCaptureFileOutput,
    didFinishRecordingTo outputFileURL: URL,
    from _: [AVCaptureConnection],
    error: Error?)
  {
    AespaLogger.log(message: "Recording stopped")

    if let error {
      AespaLogger.log(error: error)
      fileIOResultSubject.send(.failure(error))
    } else {
      fileIOResultSubject.send(.success(outputFileURL))
    }
  }
}
