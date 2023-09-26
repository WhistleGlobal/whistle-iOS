//
//  ProjectEntity+Ext.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import CoreData
import Foundation
import SwiftUI

extension ProjectEntity {
  var videoURL: URL? {
    guard let url else { return nil }
    return FileManager().createVideoPath(with: url)
  }

  var wrappedTools: [Int] {
    appliedTools?.components(separatedBy: ",").compactMap { Int($0) } ?? []
  }

  var wrappedColor: Color {
    guard let frameColor else { return .blue }
    return Color(hex: frameColor)
  }

  var uiImage: UIImage {
    if let id, let uImage = FileManager().retrieveImage(with: id) {
      return uImage
    } else {
      return UIImage(systemName: "exclamationmark.circle")!
    }
  }

  static func request() -> NSFetchRequest<ProjectEntity> {
    let request = NSFetchRequest<ProjectEntity>(entityName: "ProjectEntity")
    request.sortDescriptors = [NSSortDescriptor(key: "createAt", ascending: true)]
    return request
  }

  static func create(video: EditableVideo, context: NSManagedObjectContext) {
    let project = ProjectEntity(context: context)
    let id = UUID().uuidString
    if let image = video.thumbnailsImages.first?.image {
      FileManager.default.saveImage(with: id, image: image)
    }
    project.id = id
    project.createAt = Date.now
    project.url = video.url.lastPathComponent
    project.rotation = video.rotation
    project.rate = Double(video.rate)
    project.isMirror = video.isMirror
    project.filterName = video.filterName
    project.lowerBound = video.rangeDuration.lowerBound
    project.upperBound = video.rangeDuration.upperBound

    context.saveContext()
  }

  static func update(for video: EditableVideo, project: ProjectEntity) {
    if let context = project.managedObjectContext {
      project.isMirror = video.isMirror
      project.lowerBound = video.rangeDuration.lowerBound
      project.upperBound = video.rangeDuration.upperBound
      project.filterName = video.filterName
      project.saturation = video.colorCorrection.saturation
      project.contrast = video.colorCorrection.contrast
      project.brightness = video.colorCorrection.brightness
      project.appliedTools = video.toolsApplied.map { String($0) }.joined(separator: ",")
      project.rotation = video.rotation
      project.rate = Double(video.rate)
      project.frameColor = video.videoFrames?.frameColor.toHex()
      project.frameScale = video.videoFrames?.scaleValue ?? 0

      if let audio = video.audio {
        project.audio = AudioEntity.createAudio(
          context: context,
          url: audio.url.absoluteString,
          duration: audio.duration)
      } else {
        project.audio = nil
      }

      context.saveContext()
    }
  }

  static func remove(_ item: ProjectEntity) {
    if let context = item.managedObjectContext, let id = item.id, let url = item.url {
      let manager = FileManager.default
      manager.deleteImage(with: id)
      manager.deleteVideo(with: url)
      context.delete(item)
      context.saveContext()
    }
  }
}

extension NSManagedObjectContext {
  func saveContext() {
    if hasChanges {
      do {
        try save()
      } catch {
        let nsError = error as NSError
        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
      }
    }
  }
}
