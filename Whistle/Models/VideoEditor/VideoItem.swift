//
//  VideoItem.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import AVKit
import SwiftUI

struct VideoItem: Transferable {
  let url: URL

  static var transferRepresentation: some TransferRepresentation {
    FileRepresentation(contentType: .movie) { movie in
      SentTransferredFile(movie.url)
    } importing: { received in
      let id = UUID().uuidString
      let copy = URL.documentsDirectory.appending(path: "\(id).mp4")

      if FileManager.default.fileExists(atPath: copy.path()) {
        try FileManager.default.removeItem(at: copy)
      }

      try FileManager.default.copyItem(at: received.file, to: copy)
      return Self(url: copy)
    }
  }
}
