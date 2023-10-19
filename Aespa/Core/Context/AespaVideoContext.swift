//
//  AespaVideoContext.swift
//
//
//  Created by 이영빈 on 2023/06/22.
//

import UIKit

import AVFoundation
import Combine
import Foundation

// MARK: - AespaVideoContext

/// `AespaVideoContext` is an open class that provides a context for video recording operations.
/// It has methods and properties to handle the video recording and settings.
public class AespaVideoContext<Common: CommonContext> {
  private let commonContext: Common
  private let coreSession: AespaCoreSession
  private let albumManager: AespaCoreAlbumManager
  private let option: AespaOption

  private let recorder: AespaCoreRecorder

  private let videoFileBufferSubject: CurrentValueSubject<Result<URL, Error>?, Never>

  /// A Boolean value that indicates whether the session is currently recording video.
  public var isRecording: Bool

  init(
    commonContext: Common,
    coreSession: AespaCoreSession,
    recorder: AespaCoreRecorder,
    albumManager: AespaCoreAlbumManager,
    option: AespaOption)
  {
    self.commonContext = commonContext
    self.coreSession = coreSession
    self.recorder = recorder
    self.albumManager = albumManager
    self.option = option

    videoFileBufferSubject = .init(nil)

    isRecording = false

    // Add first video file to buffer if it exists
    if option.asset.synchronizeWithLocalAlbum {
      Task(priority: .utility) {
//        guard let firstVideoAsset = await albumManager.fetchVideoFile(limit: 1).first else {
//          return
//        }

//                videoFileBufferSubject.send(.success(firstVideoAsset.toVideoFile))
      }
    }
  }
}

// MARK: VideoContext

extension AespaVideoContext: VideoContext {
  public var underlyingVideoContext: AespaVideoContext {
    self
  }

  public var isMuted: Bool {
    coreSession.audioDeviceInput == nil
  }

  public var videoFilePublisher: AnyPublisher<Result<URL, Error>, Never> {
    videoFileBufferSubject.handleEvents(receiveOutput: { status in
      if case .failure(let error) = status {
        Logger.log(error: error)
      }
    })
    .compactMap { $0 }
    .eraseToAnyPublisher()
  }

  public func startRecording(at path: URL? = nil, _ onComplete: @escaping CompletionHandler = { _ in }) {
    let fileName = option.asset.fileNameHandler()
    let filePath = path ?? FilePathProvider.requestTemporaryFilePath(
      fileName: fileName,
      extension: option.asset.fileExtension)

    if option.session.autoVideoOrientationEnabled {
      commonContext.orientation(to: UIDevice.current.orientation.toVideoOrientation, onComplete)
    }

    recorder.startRecording(in: filePath, onComplete)
    isRecording = true
  }

  public func stopRecording(_ onCompelte: @escaping ResultHandler<URL> = { _ in }) {
    Task(priority: .utility) {
      do {
        let videoFilePath = try await recorder.stopRecording()

//                if option.asset.synchronizeWithLocalAlbum {
//                    try await albumManager.addToAlbum(filePath: videoFilePath)
//                    // delete
//                }

//                let videoFile = VideoFileGenerator.generate(with: videoFilePath, date: Date())
        videoFileBufferSubject.send(.success(videoFilePath))

        isRecording = false
        onCompelte(.success(videoFilePath))
      } catch {
        Logger.log(error: error)
        onCompelte(.failure(error))
      }
    }
  }

  @discardableResult
  public func mute(_ onComplete: @escaping CompletionHandler = { _ in }) -> AespaVideoContext {
    let tuner = AudioTuner(isMuted: true)
    coreSession.run(tuner, onComplete)

    return self
  }

  @discardableResult
  public func unmute(_ onComplete: @escaping CompletionHandler = { _ in }) -> AespaVideoContext {
    let tuner = AudioTuner(isMuted: false)
    coreSession.run(tuner, onComplete)

    return self
  }

  @discardableResult
  public func stabilization(
    mode: AVCaptureVideoStabilizationMode,
    _ onComplete: @escaping CompletionHandler = { _ in })
    -> AespaVideoContext
  {
    let tuner = VideoStabilizationTuner(stabilzationMode: mode)
    coreSession.run(tuner, onComplete)

    return self
  }

  @discardableResult
  public func torch(
    mode: AVCaptureDevice.TorchMode,
    level: Float,
    _ onComplete: @escaping CompletionHandler = { _ in })
    -> AespaVideoContext
  {
    let tuner = TorchTuner(level: level, torchMode: mode)
    coreSession.run(tuner, onComplete)

    return self
  }

  public func customize(
    _ tuner: some AespaSessionTuning,
    _ onComplete: @escaping CompletionHandler = { _ in })
    -> AespaVideoContext
  {
    coreSession.run(tuner, onComplete)

    return self
  }

//  public func fetchVideoFiles(limit: Int = 0) async -> [VideoAsset] {
//    guard option.asset.synchronizeWithLocalAlbum else {
//      Logger.log(
//        message:
//        "'option.asset.synchronizeWithLocalAlbum' is set to false" +
//          "so no photos will be fetched from the local album. " +
//          "If you intended to fetch photos," +
//          "please ensure 'option.asset.synchronizeWithLocalAlbum' is set to true.")
//      return []
//    }
//
//    return await albumManager.fetchVideoFile(limit: limit)
//  }
}
