//
//  EditableVideo.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import AVKit
import SwiftUI

// MARK: - EditableVideo

struct EditableVideo: Identifiable {
  var id: UUID = .init()
  var url: URL
  var asset: AVAsset
  let originalDuration: Double
  var rangeDuration: ClosedRange<Double>
  var thumbnailsImages = [ThumbnailImage]()
  var thumbHQImages = [ThumbnailImage]()
  var rate: Float = 1.0
  var rotation: Double = 0
  var frameSize: CGSize = .zero
  var geometrySize: CGSize = .zero
  var isMirror = false
  var toolsApplied = [Int]()
  var filterName: String? = nil
  var colorCorrection = ColorCorrection()
  var videoFrames: VideoFrames? = nil
  var audio: Audio?
  var volume: Float = 1.0

  var totalDuration: Double {
    rangeDuration.upperBound - rangeDuration.lowerBound
  }

  init(url: URL) {
    self.url = url
    asset = AVAsset(url: url)
    originalDuration = asset.videoDuration()
    rangeDuration = 0 ... originalDuration
  }

  init(url: URL, rangeDuration: ClosedRange<Double>, rate: Float = 1.0, rotation: Double = 0) {
    self.url = url
    asset = AVAsset(url: url)
    originalDuration = asset.videoDuration()
    self.rangeDuration = rangeDuration
    self.rate = rate
    self.rotation = rotation
  }

  mutating func updateThumbnails() {
//    let imagesCount = thumbnailCount(geo)
    let imagesCount = 21

    var offset: Float64 = 0
    for i in 0 ... imagesCount {
      let thumbnailImage = ThumbnailImage(image: asset.getImage(Int(offset)))
      offset = Double(i) * (originalDuration / Double(imagesCount))
      thumbnailsImages.append(thumbnailImage)
    }
    thumbnailsImages.remove(at: 0)
  }

  mutating func generateHQThumbnails() {
    let imagesCount = 21
    var offset: Float64 = 0
    for i in 0 ... imagesCount {
      let thumbnailImage = ThumbnailImage(image: asset.getImage(Int(offset), compressionQuality: 1.0))
      offset = Double(i) * (originalDuration / Double(imagesCount))

      thumbHQImages.append(thumbnailImage)
    }
    thumbHQImages.remove(at: 0)
  }

  /// reset and update
  mutating func updateRate(_ rate: Float) {
    let lowerBound = (rangeDuration.lowerBound * Double(self.rate)) / Double(rate)
    let upperBound = (rangeDuration.upperBound * Double(self.rate)) / Double(rate)
    rangeDuration = lowerBound ... upperBound

    self.rate = rate
  }

  mutating func resetRangeDuration() {
    rangeDuration = 0 ... originalDuration
  }

  mutating func resetRate() {
    updateRate(1.0)
  }

  mutating func rotate() {
    rotation = rotation.nextAngle()
  }

  mutating func appliedTool(for tool: ToolEnum) {
    if !isAppliedTool(for: tool) {
      toolsApplied.append(tool.rawValue)
    }
  }

  mutating func setVolume(_ value: Float) {
    volume = value
  }

  mutating func removeTool(for tool: ToolEnum) {
    if isAppliedTool(for: tool) {
      toolsApplied.removeAll(where: { $0 == tool.rawValue })
    }
  }

  mutating func setFilter(_ filter: String?) {
    filterName = filter
  }

  func isAppliedTool(for tool: ToolEnum) -> Bool {
    toolsApplied.contains(tool.rawValue)
  }

  private func thumbnailCount(_ geo: GeometryProxy) -> Int {
    let num = Double(geo.size.width - 32) / Double(70 / 1.5)

    return Int(ceil(num))
  }

  static var mock: EditableVideo = .init(url: URL(string: "https://www.google.com/")!, rangeDuration: 0 ... 250)
}

// MARK: Equatable

extension EditableVideo: Equatable {
  static func == (lhs: EditableVideo, rhs: EditableVideo) -> Bool {
    lhs.id == rhs.id
  }
}

extension Double {
  func nextAngle() -> Double {
    var next = Int(self) + 90
    if next >= 360 {
      next = 0
    } else if next < 0 {
      next = 360 - abs(next % 360)
    }
    return Double(next)
  }
}

// MARK: - ThumbnailImage

struct ThumbnailImage: Identifiable {
  var id: UUID = .init()
  var image: UIImage?

  //  init(image: UIImage? = nil) {
//    self.image = image?.resize(to: .init(width: 500, height: 700))
  ////    self.image = image?.resize
  //  }
}

// MARK: - VideoFrames

struct VideoFrames {
  var scaleValue: Double = 0
  var frameColor: Color = .white

  var scale: Double {
    1 - scaleValue
  }

  var isActive: Bool {
    scaleValue > 0
  }

  mutating func reset() {
    scaleValue = 0
    frameColor = .white
  }
}
