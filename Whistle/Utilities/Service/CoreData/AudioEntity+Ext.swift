//
//  AudioEntity+Ext.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import CoreData
import Foundation

extension AudioEntity {
  var audioModel: Audio? {
    guard let urlStr = url, let url = URL(string: urlStr) else { return nil }
    return .init(url: url, duration: duration)
  }

  static func createAudio(context: NSManagedObjectContext, url: String, duration: Double) -> AudioEntity {
    let entity = AudioEntity(context: context)
    entity.duration = duration
    entity.url = url
    return entity
  }
}
