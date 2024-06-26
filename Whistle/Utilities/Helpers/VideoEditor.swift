//
//  VideoEditor.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import AVFoundation
import Combine
import Foundation
import UIKit

// MARK: - VideoEditor

class VideoEditor {
  @Published var currentTimePublisher: TimeInterval = 0.0

  /// The renderer is made up of half-sequential operations:
  func startRender(video: EditableVideo, videoQuality: VideoQuality, start: Double, musicVolume: Float) async throws -> URL {
    do {
      let url = try await resizeAndLayerOperation(
        video: video,
        videoQuality: videoQuality,
        start: start,
        musicVolume: musicVolume)
//      let finalURL = try await applyFiltersOperations(video, fromURL: url)
      return url
    } catch {
      throw error
    }
  }

  /// Cut, resizing, rotate and set quality
  private func resizeAndLayerOperation(
    video: EditableVideo,
    videoQuality _: VideoQuality,
    start: Double,
    musicVolume: Float)
    async throws -> URL
  {
    let composition = AVMutableComposition()

    let timeRange = getTimeRange(for: video.originalDuration, with: video.rangeDuration)
    let asset = video.asset
    let audioMix = AVMutableAudioMix()
    var mixParameters = [AVMutableAudioMixInputParameters]()

    /// Set new timeScale
    try await setTimeScaleAndAddTracks(
      to: composition,
      from: asset,
      audio: video.audio,
      timeScale: Float64(video.rate),
      videoVolume: video.volume,
      musicVolume: musicVolume,
      start: start,
      audioMix: audioMix,
      audioParameter: &mixParameters)

    /// Get new timeScale video track
    guard let videoTrack = try await composition.loadTracks(withMediaType: .video).first else {
      throw ExporterError.unknow
    }

    let videoTracks = try await composition.loadTracks(withMediaType: .video)
    WhistleLogger.logger.debug("videoTracks1: \(videoTracks)")

    /// Prepair new video size
    let naturalSize = videoTrack.naturalSize
    let videoTrackPreferredTransform = try await videoTrack.load(.preferredTransform)

    /// export 영상 사이즈 지정
    let outputSize = getSizeFromOrientation(
      newSize: naturalSize,
      videoTrackPreferredTransform: videoTrackPreferredTransform)

    /// Create layerInstructions and set new size, scale, mirror
    let layerInstruction = videoCompositionInstructionForTrackWithSizeAndTime(
      preferredTransform: videoTrackPreferredTransform,
      naturalSize: naturalSize,
      newSize: outputSize,
      track: videoTrack,
      scale: video.videoFrames?.scale ?? 1,
      isMirror: video.isMirror)

    /// Create mutable video composition
    let videoComposition = AVMutableVideoComposition()
    /// Set render video  size
    videoComposition.renderSize = outputSize
    /// Set frame duration 30fps
    videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)

    audioMix.inputParameters = mixParameters

    /// Create background layer color and scale video
    createLayers(video.videoFrames, video: video, size: outputSize, videoComposition: videoComposition)

    /// Set Video Composition Instruction
    let instruction = AVMutableVideoCompositionInstruction()

    /// Set time range
    instruction.timeRange = timeRange
    instruction.layerInstructions = [layerInstruction]

    /// Set instruction in videoComposition
    videoComposition.instructions = [instruction]

    /// Create file path in temp directory
    let outputURL = createTempPath()

    /// Create exportSession
    let session = try exportSession(
      audioMix: audioMix,
      composition: composition,
      videoComposition: videoComposition,
      outputURL: outputURL,
      timeRange: timeRange)

    await session.export()

    if let error = session.error {
      throw error
    } else {
      if let url = session.outputURL {
        return url
      }
      throw ExporterError.failed
    }
  }

  /// Adding filters
  private func applyFiltersOperations(_ video: EditableVideo, fromURL: URL) async throws -> URL {
    let filters = VideoFilterHelpers.createFilters(mainFilter: CIFilter(name: video.filterName ?? ""), video.colorCorrection)

    if filters.isEmpty {
      return fromURL
    }
    let asset = AVAsset(url: fromURL)
    let composition = asset.setFilters(filters)

    let outputURL = createTempPath()
    // export the video to as per your requirement conversion

    /// Create exportSession
    guard
      let session = AVAssetExportSession(
        asset: asset,
        presetName: isSimulator ? AVAssetExportPresetPassthrough : AVAssetExportPresetHighestQuality)
    else {
      WhistleLogger.logger.debug("Cannot create export session.")
      throw ExporterError.cannotCreateExportSession
    }
    session.videoComposition = composition
    session.outputFileType = .mp4
    session.outputURL = outputURL

    await session.export()

    if let error = session.error {
      throw error
    } else {
      if let url = session.outputURL {
        return url
      }
      throw ExporterError.failed
    }
  }
}

// MARK: - VideoFilterHelpers

extension VideoEditor {
  private func exportSession(
    audioMix: AVMutableAudioMix,
    composition: AVMutableComposition,
    videoComposition: AVMutableVideoComposition,
    outputURL: URL,
    timeRange: CMTimeRange)
    throws -> AVAssetExportSession
  {
    guard
      let export = AVAssetExportSession(
        asset: composition,
        presetName: AVAssetExportPresetHighestQuality)
    else {
      WhistleLogger.logger.debug("Cannot create export session.")
      throw ExporterError.cannotCreateExportSession
    }
    export.audioMix = audioMix
    export.videoComposition = videoComposition
    export.shouldOptimizeForNetworkUse = true
    export.outputFileType = .mp4
    export.outputURL = outputURL
    export.timeRange = timeRange

    return export
  }

  private func createLayers(
    _ videoFrame: VideoFrames?,
    video _: EditableVideo,
    size: CGSize,
    videoComposition: AVMutableVideoComposition)
  {
    guard let videoFrame else { return }

    let color = videoFrame.frameColor
    let scale = videoFrame.scale
    let scaleSize = CGSize(width: size.width * scale, height: size.height * scale)
    let centerPoint = CGPoint(x: (size.width - scaleSize.width) / 2, y: (size.height - scaleSize.height) / 2)

    let videoLayer = CALayer()
    videoLayer.frame = CGRect(origin: centerPoint, size: scaleSize)
    let bgLayer = CALayer()
    bgLayer.frame = CGRect(origin: .zero, size: size)
    bgLayer.backgroundColor = UIColor(color).cgColor

    let outputLayer = CALayer()
    outputLayer.frame = CGRect(origin: .zero, size: size)

    outputLayer.addSublayer(bgLayer)
    outputLayer.addSublayer(videoLayer)

    videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(
      postProcessingAsVideoLayer: videoLayer,
      in: outputLayer)
  }

  /// Set new time scale for audio and video tracks
  private func setTimeScaleAndAddTracks(
    to composition: AVMutableComposition,
    from asset: AVAsset,
    audio: Audio?,
    timeScale: Float64,
    videoVolume: Float,
    musicVolume: Float,
    start: Double,
    audioMix _: AVMutableAudioMix,
    audioParameter: inout [AVMutableAudioMixInputParameters])
    async throws
  {
    let videoTracks = try await asset.loadTracks(withMediaType: .video)
    WhistleLogger.logger.debug("videoTracks2: \(videoTracks)")
    let audioTracks = try await asset.loadTracks(withMediaType: .audio)

    let duration = try await asset.load(.duration)
    // TotalTimeRange
    let oldTimeRange = CMTimeRangeMake(start: CMTime.zero, duration: duration)
    let destinationTimeRange = CMTimeMultiplyByFloat64(duration, multiplier: 1 / timeScale)
    // set new time range in audio track
    if !audioTracks.isEmpty {
      let audioCompositionTrack = composition.addMutableTrack(
        withMediaType: .audio,
        preferredTrackID: .init())
      audioCompositionTrack?.preferredVolume = videoVolume
      let audioAssetTrack = audioTracks.first!
      let audioParams = AVMutableAudioMixInputParameters(track: audioAssetTrack)
      audioParams.trackID = audioCompositionTrack!.trackID
      audioParams.setVolume(videoVolume, at: .zero)
      audioParameter.append(audioParams)
      try audioCompositionTrack?.insertTimeRange(oldTimeRange, of: audioAssetTrack, at: CMTime.zero)
      audioCompositionTrack?.scaleTimeRange(oldTimeRange, toDuration: destinationTimeRange)

      let audioPreferredTransform = try await audioAssetTrack.load(.preferredTransform)
      audioCompositionTrack?.preferredTransform = audioPreferredTransform
    }

    // set new time range in video track
    if !videoTracks.isEmpty {
      let videoCompositionTrack = composition.addMutableTrack(
        withMediaType: .video,
        preferredTrackID: .init())

      let videoAssetTrack = videoTracks.first!
      try videoCompositionTrack?.insertTimeRange(oldTimeRange, of: videoAssetTrack, at: CMTime.zero)
      videoCompositionTrack?.scaleTimeRange(oldTimeRange, toDuration: destinationTimeRange)

      let videoPreferredTransform = try await videoAssetTrack.load(.preferredTransform)
      videoCompositionTrack?.preferredTransform = videoPreferredTransform
    }

//     Adding audio
    if let audio {
      let asset = AVAsset(url: audio.url)
      guard let musicAssetTrack = try await asset.loadTracks(withMediaType: .audio).first else { return }
      let musicCompositionTrack = composition.addMutableTrack(
        withMediaType: .audio,
        preferredTrackID: .init())
      musicCompositionTrack?.preferredVolume = 0
      let musicParams = AVMutableAudioMixInputParameters(track: musicAssetTrack)
      musicParams.trackID = musicCompositionTrack!.trackID
      musicParams.setVolume(musicVolume, at: .zero)
      audioParameter.append(musicParams)
      try musicCompositionTrack?.insertTimeRange(
        oldTimeRange,
        of: musicAssetTrack,
        at: CMTimeMakeWithSeconds(start, preferredTimescale: 1000))
      musicCompositionTrack?.scaleTimeRange(oldTimeRange, toDuration: destinationTimeRange)
      let musicPreferredTransform = try await musicAssetTrack.load(.preferredTransform)
      musicCompositionTrack?.preferredTransform = musicPreferredTransform
    }
  }

  /// create CMTimeRange
  private func getTimeRange(for duration: Double, with timeRange: ClosedRange<Double>) -> CMTimeRange {
    let start = timeRange.lowerBound.clamped(to: 0 ... duration)
    let end = timeRange.upperBound.clamped(to: start ... duration)

    let startTime = CMTimeMakeWithSeconds(start, preferredTimescale: 1000)
    let endTime = CMTimeMakeWithSeconds(end, preferredTimescale: 1000)

    let timeRange = CMTimeRangeFromTimeToTime(start: startTime, end: endTime)
    return timeRange
  }

  /// set video size for AVMutableVideoCompositionLayerInstruction
  private func videoCompositionInstructionForTrackWithSizeAndTime(
    preferredTransform: CGAffineTransform,
    naturalSize: CGSize,
    newSize: CGSize,
    track: AVAssetTrack,
    scale _: Double,
    isMirror: Bool)
    -> AVMutableVideoCompositionLayerInstruction
  {
    let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
    let assetInfo = orientationFromTransform(preferredTransform)

    var aspectFillRatio: CGFloat = 1
    if naturalSize.height < naturalSize.width {
//      aspectFillRatio = newSize.height / naturalSize.height
      aspectFillRatio = 1
    } else {
//      aspectFillRatio = newSize.width / naturalSize.width
      aspectFillRatio = 1
    }

    let scaleFactor = CGAffineTransform(scaleX: aspectFillRatio, y: aspectFillRatio)

    if assetInfo.isPortrait {
      let posX = newSize.width / 2 - (naturalSize.height * aspectFillRatio) / 2
      let posY = newSize.height / 2 - (naturalSize.width * aspectFillRatio) / 2
      let moveFactor = CGAffineTransform(translationX: posX, y: posY)
      instruction.setTransform(preferredTransform.concatenating(scaleFactor).concatenating(moveFactor), at: .zero)

    } else {
      let posX = newSize.width / 2 - (naturalSize.width * aspectFillRatio) / 2
      let posY = newSize.height / 2 - (naturalSize.height * aspectFillRatio) / 2
      let moveFactor = CGAffineTransform(translationX: posX, y: posY)

      var concat = preferredTransform.concatenating(scaleFactor).concatenating(moveFactor)

      if assetInfo.orientation == .down {
        let fixUpsideDown = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        concat = fixUpsideDown.concatenating(scaleFactor).concatenating(moveFactor)
      }
      instruction.setTransform(concat, at: .zero)
    }

    if isMirror {
      var transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
      transform = transform.translatedBy(x: -newSize.width, y: 0.0)
      instruction.setTransform(transform, at: .zero)
    }

    return instruction
  }

  private func getSizeFromOrientation(newSize: CGSize, videoTrackPreferredTransform: CGAffineTransform) -> CGSize {
    let orientation = orientationFromTransform(videoTrackPreferredTransform)
    var outputSize = newSize
    if orientation.isPortrait {
      outputSize.width = newSize.height
      outputSize.height = newSize.width
    }
    return outputSize
  }

  private func orientationFromTransform(_ transform: CGAffineTransform)
    -> (orientation: UIImage.Orientation, isPortrait: Bool)
  {
    var assetOrientation = UIImage.Orientation.up
    var isPortrait = false
    if transform.a == 0, transform.b == 1.0, transform.c == -1.0, transform.d == 0 {
      assetOrientation = .right
      isPortrait = true
    } else if transform.a == 0, transform.b == -1.0, transform.c == 1.0, transform.d == 0 {
      assetOrientation = .left
      isPortrait = true
    } else if transform.a == 1.0, transform.b == 0, transform.c == 0, transform.d == 1.0 {
      assetOrientation = .up
    } else if transform.a == -1.0, transform.b == 0, transform.c == 0, transform.d == -1.0 {
      assetOrientation = .down
    }
    return (assetOrientation, isPortrait)
  }

  private func createTempPath() -> URL {
    let tempPath = "\(NSTemporaryDirectory())_\(Date.now.formatted(date: .abbreviated, time: .complete)).mp4"
    let tempURL = URL(fileURLWithPath: tempPath)
    FileManager.default.removefileExists(for: tempURL)
    return tempURL
  }

  /// needed for simulator fix AVVideoCompositionCoreAnimationTool crash only in simulator
  private var isSimulator: Bool {
    #if targetEnvironment(simulator)
    true
    #else
    false
    #endif
  }

  private func addImage(
    to layer: CALayer,
    watermark: UIImage,
    videoSize: CGSize)
  {
    let imageLayer = CALayer()
    let aspect: CGFloat = watermark.size.width / watermark.size.height
    let width = videoSize.width / 4
    let height = width / aspect
    imageLayer.frame = CGRect(
      x: width,
      y: 0,
      width: width,
      height: height)
    imageLayer.contents = watermark.cgImage
    layer.addSublayer(imageLayer)
  }

  func convertSize(
    _ size: CGSize,
    fromFrame frameSize1: CGSize,
    toFrame frameSize2: CGSize) -> (size: CGSize, ratio: Double)
  {
    let widthRatio = frameSize2.width / frameSize1.width
    let heightRatio = frameSize2.height / frameSize1.height
    let ratio = max(widthRatio, heightRatio)
    let newSizeWidth = size.width * ratio
    let newSizeHeight = size.height * ratio

    let newSize = CGSize(width: (frameSize2.width / 2) + newSizeWidth, height: (frameSize2.height / 2) + -newSizeHeight)

    return (CGSize(width: newSize.width, height: newSize.height), ratio)
  }
}

// MARK: - ExporterError

enum ExporterError: Error, LocalizedError {
  case unknow
  case cancelled
  case cannotCreateExportSession
  case failed
}

extension Double {
  func clamped(to range: ClosedRange<Double>) -> Double {
    min(max(self, range.lowerBound), range.upperBound)
  }

  var degTorad: Double {
    self * .pi / 180
  }
}
