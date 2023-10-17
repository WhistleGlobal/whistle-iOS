//
//  Context.swift
//
//
//  Created by 이영빈 on 2023/06/24.
//

import AVFoundation
import Combine
import Foundation
import UIKit

/// A type representing a closure that handles a completion event with potential errors.
public typealias CompletionHandler = (Result<Void, Error>) -> Void

/// A type representing a closure that handles a result of an operation
/// that produces a value of type `T`, with potential errors.
public typealias ResultHandler<T> = (Result<T, Error>) -> Void

// MARK: - CommonContext

/// A protocol that defines the common behaviors and properties that all context types must implement.
///
/// It includes methods to control the quality, position, orientation, and auto-focusing behavior
/// of the session. It also includes the ability to adjust the zoom level of the session.
public protocol CommonContext {
  ///
  associatedtype CommonContextType: CommonContext & VideoContext & PhotoContext
  ///
  var underlyingCommonContext: CommonContextType { get }

  /// Sets the quality preset for the video recording session.
  ///
  /// - Parameters:
  ///   - preset: An `AVCaptureSession.Preset` value indicating the quality preset to be set.
  ///   - onComplete: A closure to be executed if the session fails to run the tuner.
  ///
  /// - Returns: `AespaVideoContext`, for chaining calls.
  @discardableResult
  func quality(
    to preset: AVCaptureSession.Preset,
    _ onComplete: @escaping CompletionHandler) -> CommonContextType

  /// Sets the camera position for the video recording session.
  ///
  /// It refers to `AespaOption.Session.cameraDevicePreference` when choosing the camera device.
  ///
  /// - Parameters:
  ///   - position: An `AVCaptureDevice.Position` value indicating the camera position to be set.
  ///   - onComplete: A closure to be executed if the session fails to run the tuner.
  ///
  /// - Returns: `AespaVideoContext`, for chaining calls.
  @discardableResult
  func position(
    to position: AVCaptureDevice.Position,
    _ onComplete: @escaping CompletionHandler) -> CommonContextType

  /// Sets the orientation for the session.
  ///
  /// - Parameters:
  ///   - orientation: An `AVCaptureVideoOrientation` value indicating the orientation to be set.
  ///   - onComplete: A closure to be executed if the session fails to run the tuner.
  ///
  /// - Returns: `AespaVideoContext`, for chaining calls.
  ///
  /// - Note: It sets the orientation of the video you are recording,
  ///     not the orientation of the `AVCaptureVideoPreviewLayer`.
  @discardableResult
  func orientation(
    to orientation: AVCaptureVideoOrientation,
    _ onComplete: @escaping CompletionHandler) -> CommonContextType

  /// Sets the autofocusing mode for the video recording session.
  ///
  /// - Parameters:
  ///   - mode: The focus mode(`AVCaptureDevice.FocusMode`) for the session.
  ///   - point: The point in the camera's field of view that the auto focus should prioritize.
  ///   - onComplete: A closure to be executed if the session fails to run the tuner.
  ///
  /// - Returns: `AespaVideoContext`, for chaining calls.
  @discardableResult
  func focus(
    mode: AVCaptureDevice.FocusMode,
    point: CGPoint?,
    _ onComplete: @escaping CompletionHandler) -> CommonContextType

  /// Sets the zoom factor for the video recording session.
  ///
  /// - Parameters:
  ///   - factor: A `CGFloat` value indicating the zoom factor to be set.
  ///   - onComplete: A closure to be executed if the session fails to run the tuner.
  ///
  /// - Returns: `AespaVideoContext`, for chaining calls.
  @discardableResult
  func zoom(factor: CGFloat, _ onComplete: @escaping CompletionHandler) -> CommonContextType

  /// Changes monitoring status.
  ///
  /// - Parameters:
  ///   - enabled: A boolean value to set monitoring status.
  ///   - onComplete: A closure to be executed if the session fails to run the tuner.
  ///
  /// - Returns: `AespaVideoContext`, for chaining calls.
  @discardableResult
  func changeMonitoring(
    enabled: Bool,
    _ onComplete: @escaping CompletionHandler) -> CommonContextType

  /// This function provides a way to use a custom tuner to modify the current session.
  /// The tuner must conform to `AespaSessionTuning`.
  ///
  /// - Parameters:
  ///   - tuner: An instance that conforms to `AespaSessionTuning`.
  ///   - onComplete: A closure to be executed if the session fails to run the tuner.
  ///
  /// - Returns: `AespaVideoContext`, for chaining calls.
  @discardableResult
  func custom<T: AespaSessionTuning>(
    _ tuner: T,
    _ onComplete: @escaping CompletionHandler) -> CommonContextType
}

// MARK: - VideoContext

/// A protocol that defines the behaviors and properties specific to the video context.
///
/// It adds video-specific capabilities such as checking if
/// the session is currently recording or muted, and controlling video recording,
/// stabilization, torch mode, and fetching recorded video files.
public protocol VideoContext {
  ///
  associatedtype VideoContextType: VideoContext
  ///
  var underlyingVideoContext: VideoContextType { get }

  /// A Boolean value that indicates whether the session is currently recording video.
  var isRecording: Bool { get }

  /// This publisher is responsible for emitting `VideoFile` objects resulting from completed recordings.
  ///
  /// In the case of an error, it logs the error before forwarding it wrapped in a `Result.failure`.
  /// If you don't want to show logs, set `enableLogging` to `false` from `AespaOption.Log`
  ///
  /// - Returns: `VideoFile` wrapped in a `Result` type.
  var videoFilePublisher: AnyPublisher<Result<URL, Error>, Never> { get }

  /// This property reflects the current state of audio input.
  ///
  /// If it returns `true`, the audio input is currently muted.
  var isMuted: Bool { get }

  /// Starts the video recording session.
  ///
  /// - Parameter onComplete: A closure to handle any errors that occur during recording.
  ///
  /// - Note: If `autoVideoOrientation` option is enabled,
  ///   it sets the orientation according to the current device orientation.
  func startRecording(at path: URL?, _ onComplete: @escaping CompletionHandler)

  /// Stops the current recording session and saves the video file.
  ///
  /// Once the recording session is successfully stopped and the video file is saved,
  /// this function invokes a completion handler with the resulting `VideoFile` instance or an error.
  ///
  /// - Parameter onComplete: A closure to be called after the recording has stopped
  ///  and the video file is saved or failed.
  func stopRecording(_ onComplete: @escaping (Result<URL, Error>) -> Void)

  /// Mutes the audio input for the video recording session.
  ///
  /// - Parameter onComplete: A closure to handle any errors that occur when muting the audio.
  ///
  /// - Returns: The modified `VideoContextType` for chaining calls.
  @discardableResult
  func mute(_ onComplete: @escaping CompletionHandler) -> VideoContextType

  /// Unmutes the audio input for the video recording session.
  ///
  /// - Parameter onComplete: A closure to handle any errors that occur when unmuting the audio.
  ///
  /// - Returns: The modified `VideoContextType` for chaining calls.
  @discardableResult
  func unmute(_ onComplete: @escaping CompletionHandler) -> VideoContextType

  /// Sets the stabilization mode for the video recording session.
  ///
  /// - Parameters:
  ///   - mode: An `AVCaptureVideoStabilizationMode` value indicating the stabilization mode to be set.
  ///   - onComplete: A closure to handle any errors that occur when setting the stabilization mode.
  ///
  /// - Returns: The modified `VideoContextType` for chaining calls.
  @discardableResult
  func stabilization(
    mode: AVCaptureVideoStabilizationMode,
    _ onComplete: @escaping CompletionHandler) -> VideoContextType

  /// Sets the torch mode and level for the video recording session.
  ///
  /// - Parameters:
  ///   - mode: The desired torch mode (AVCaptureDevice.TorchMode).
  ///   - level: The desired torch level as a Float between 0.0 and 1.0.
  ///
  /// - Returns: Returns self, allowing additional settings to be configured.
  ///
  /// - Note: This function might throw an error if the torch mode is not supported,
  ///   or the specified level is not within the acceptable range.
  @discardableResult
  func torch(
    mode: AVCaptureDevice.TorchMode,
    level: Float,
    _ onComplete: @escaping CompletionHandler) -> VideoContextType

  /// Asynchronously fetches a specified number of `VideoAsset` instances from local album.
  ///
  /// - Parameter limit: The maximum number of video files to fetch.
  ///     Pass `0` to fetch all assets in the album.
  ///
  /// - Returns: An array of `VideoAsset` instances, representing the fetched video files.
  func fetchVideoFiles(limit: Int) async -> [VideoAsset]
}

// MARK: - PhotoContext

/// A protocol that defines the behaviors and properties specific to the photo context.
///
/// It adds photo-specific capabilities such as accessing
/// current photo settings, controlling flash mode, and red-eye reduction, capturing
/// photo, and fetching captured photo files.
public protocol PhotoContext {
  ///
  associatedtype PhotoContextType: PhotoContext
  ///
  var underlyingPhotoContext: PhotoContextType { get }

  /// The publisher that broadcasts the result of a photo file operation.
  /// It emits a `Result` object containing a `PhotoFile` on success or an `Error` on failure,
  /// and never fails itself. This can be used to observe the photo capturing process and handle
  /// the results asynchronously.
  var photoFilePublisher: AnyPublisher<Result<PhotoFile, Error>, Never> { get }

  /// A variable holding current `AVCapturePhotoSettings`
  var currentSetting: AVCapturePhotoSettings { get }

  /// Asynchronously captures a photo using the specified `AVCapturePhotoSettings`.
  ///
  /// If the photo capture is successful, it will return a `PhotoFile`
  /// object through the provided completion handler.
  ///
  /// In case of an error during the photo capture process, the error will be logged and also returned via
  /// the completion handler.
  ///
  /// - Parameters:
  ///   - completionHandler: A closure to be invoked once the photo capture process is completed. This
  ///     closure takes a `Result` type where `Success` contains a `PhotoFile` object and
  ///     `Failure` contains an `Error` object. By default, the closure does nothing.
  ///
  func capturePhoto(
    _ completionHandler: @escaping (Result<PhotoFile, Error>) -> Void)

  /// Sets the flash mode for the camera and returns the updated `AespaPhotoContext` instance.
  /// The returned instance can be used for chaining configuration.
  ///
  /// - Parameter mode: The `AVCaptureDevice.FlashMode` to set for the camera.
  /// - Returns: The updated `AespaPhotoContext` instance.
  @discardableResult
  func flashMode(to mode: AVCaptureDevice.FlashMode) -> PhotoContextType

  /// Sets the red eye reduction mode for the camera and returns the updated `AespaPhotoContext` instance.
  /// The returned instance can be used for chaining configuration.
  ///
  /// - Parameter enabled: A boolean indicating whether the red eye reduction should be enabled or not.
  /// - Returns: The updated `AespaPhotoContext` instance.
  @discardableResult
  func redEyeReduction(enabled: Bool) -> PhotoContextType

  /// Updates the photo capturing settings for the `AespaPhotoContext` instance.
  ///
  /// - Note: This method can be potentially risky to use, as it overrides the existing capture settings.
  ///  Not all `AVCapturePhotoSettings` are supported, for instance, live photos are not supported.
  ///  It's recommended to understand the implications of the settings before applying them.
  ///
  /// - Parameter setting: The `AVCapturePhotoSettings` to use for photo capturing.
  func custom(_ setting: AVCapturePhotoSettings) -> PhotoContextType

  // MARK: - Utilities

  /// Asynchronously fetches a specified number of `PhotoAsset` instances from local album.
  ///
  /// - Parameter limit: The maximum number of photo files to fetch.
  ///     Pass `0` to fetch all assets in the album.
  ///
  /// - Returns: An array of `PhotoAsset` instances, representing the fetched photo files.
  func fetchPhotoFiles(limit: Int) async -> [PhotoAsset]
}
