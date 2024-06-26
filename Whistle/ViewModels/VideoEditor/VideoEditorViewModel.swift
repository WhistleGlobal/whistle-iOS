//
//  VideoEditorViewModel.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import AVKit
import Combine
import Foundation
import Photos
import SwiftUI

// MARK: - VideoEditorViewModel

@MainActor
class VideoEditorViewModel: ObservableObject {
  @Published var currentVideo: EditableVideo?
  @Published var selectedTools: ToolEnum?
  @Published var frames = VideoFrames()
  @Published var isSelectVideo = true

  private var projectEntity: ProjectEntity?

  func setNewVideo(_ url: URL) {
    currentVideo = .init(url: url)
    currentVideo?.updateThumbnails()
    currentVideo?.generateHQThumbnails()
    currentVideo?.updateAspectRatio()
    createProject()
  }

  func setNewUploadVideo(_ url: URL) {
    currentVideo = .init(url: url)
    createProject()
  }

  func returnThumbnail(_ index: Int) -> UIImage {
    if currentVideo?.thumbHQImages.isEmpty ?? true {
      return UIImage()
    }
    if let image = currentVideo?.thumbHQImages[index].image {
      return image
    }
    return UIImage()
  }

  func setProject(_ project: ProjectEntity) {
    projectEntity = project

    guard let url = project.videoURL else { return }

    currentVideo = .init(
      url: url,
      rangeDuration: project.lowerBound ... project.upperBound,
      rate: Float(project.rate),
      rotation: project.rotation)
    currentVideo?.toolsApplied = project.wrappedTools
    currentVideo?.filterName = project.filterName
    currentVideo?.colorCorrection = .init(
      brightness: project.brightness,
      contrast: project.contrast,
      saturation: project.saturation)
    let frame = VideoFrames(scaleValue: project.frameScale, frameColor: project.wrappedColor)
    currentVideo?.videoFrames = frame
    frames = frame
    currentVideo?.updateThumbnails()
    if let audio = project.audio?.audioModel {
      currentVideo?.audio = audio
    }
  }
}

// MARK: - Core data logic

extension VideoEditorViewModel {
  private func createProject() {
    guard let currentVideo else { return }
    let context = PersistenceController.shared.viewContext
    ProjectEntity.create(video: currentVideo, context: context)
  }

  func updateProject() {
    guard let projectEntity, let currentVideo else { return }
    ProjectEntity.update(for: currentVideo, project: projectEntity)
  }
}

// MARK: - Tools logic

extension VideoEditorViewModel {
  func setFilter(_ filter: String?) {
    currentVideo?.setFilter(filter)
    if filter != nil {
      setTools()
    } else {
      removeTool()
    }
  }

  func setFrames() {
    currentVideo?.videoFrames = frames
    setTools()
  }

  func setCorrections(_ correction: ColorCorrection) {
    currentVideo?.colorCorrection = correction
    setTools()
  }

  func updateRate(rate: Float) {
    currentVideo?.updateRate(rate)
    setTools()
  }

  func rotate() {
    currentVideo?.rotate()
    setTools()
  }

  func toggleMirror() {
    currentVideo?.isMirror.toggle()
    setTools()
  }

  func setAudio(_ audio: Audio) {
    currentVideo?.audio = audio
    setTools()
  }

  func setTools() {
    guard let selectedTools else { return }
    currentVideo?.appliedTool(for: selectedTools)
  }

  func removeTool() {
    guard let selectedTools else { return }
    currentVideo?.removeTool(for: selectedTools)
  }

  func removeAudio() {
//    guard let url = currentVideo?.audio?.url else { return }
//    FileManager.default.removefileExists(for: url)
    currentVideo?.audio = nil
    isSelectVideo = true
    removeTool()
    updateProject()
  }

//  func reset() {
//    guard let selectedTools else { return }
//
//    switch selectedTools {
  ////    case .cut:
  ////      currentVideo?.resetRangeDuration()
  ////    case .speed:
  ////      currentVideo?.resetRate()
//    case .audio, .music:
//      break
  ////    case .filters:
  ////      currentVideo?.setFilter(nil)
  ////    case .corrections:
  ////      currentVideo?.colorCorrection = ColorCorrection()
  ////    case .frames:
  ////      frames.reset()
  ////      currentVideo?.videoFrames = nil
//    }
//    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//      self.removeTool()
//    }
//  }

  func reset() {
    currentVideo = nil
    selectedTools = nil
    isSelectVideo = true
    projectEntity = nil
  }
}
