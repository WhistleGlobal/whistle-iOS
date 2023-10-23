//
//  MusicServiceProtocol.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import Foundation

protocol MusicServiceProtocol {
  func buffer(url: URL, samplesCount: Int) async throws -> [MusicNote]
}
