//
//  ToolModel.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import Foundation

enum ToolEnum: Int, CaseIterable {
  //  case cut, speed, music, audio, filters, corrections, frames
  //  case speed, music, audio, filters, corrections, frames
  case music, audio

  var title: String {
    switch self {
//    case .cut: return "Cut"
//    case .speed: return "속도"
    case .music: "음악"
    case .audio: "볼륨"
//    case .filters: return "Filters"
//    case .corrections: return "Corrections"
//    case .frames: return "Frames"
    }
  }

  var image: String {
    switch self {
//    case .cut: return "scissors"
//    case .speed: return "timer"
    case .music: "music.note"
    case .audio: "waveform"
//    case .filters: return "camera.filters"
//    case .corrections: return "circle.righthalf.filled"
//    case .frames: return "person.crop.artframe"
    }
  }
}
