//
//  MusicProtocol.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import Foundation

protocol MusicProtocol {
  func requestMusicList() async -> [Music]
}
