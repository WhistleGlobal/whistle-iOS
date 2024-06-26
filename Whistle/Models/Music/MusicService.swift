//
//  AudioService.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/05.
//
import AVFoundation
import Combine
import Foundation

// MARK: - MusicError

enum MusicError: Error {
  case invalidFormat
  case invalidData
}

// MARK: - FileDownloadError

enum FileDownloadError: Error {
  case fileCopyFailed
}

// MARK: - MusicService

class MusicService {
  static let shared: MusicServiceProtocol = MusicService()
  private init() { }
}

// MARK: MusicServiceProtocol

extension MusicService: MusicServiceProtocol {
  func buffer(url: URL, samplesCount: Int) async throws -> [MusicNote] {
    let cur_url = url

    let file = try AVAudioFile(forReading: cur_url)
    guard
      let format = AVAudioFormat(
        commonFormat: .pcmFormatFloat32,
        sampleRate: file.fileFormat.sampleRate,
        channels: file.fileFormat.channelCount,
        interleaved: false),
      let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(file.length))
    else {
      throw MusicError.invalidFormat
    }

    try file.read(into: buf)
    guard let floatChannelData = buf.floatChannelData else {
      throw MusicError.invalidData
    }

    let frameLength = Int(buf.frameLength)
    let samples = Array(UnsafeBufferPointer(start: floatChannelData[0], count: frameLength))

    var result = [MusicNote]()

    let chunked = samples.chunked(into: samples.count / samplesCount)
    for (index, row) in chunked.enumerated() {
      var accumulator: Float = 0
      let newRow = row.map { $0 * $0 }
      accumulator = newRow.reduce(0, +)
      let power: Float = accumulator / Float(row.count)
      let decibels = 10 * log10f(power)

      result.append(MusicNote(index: index, magnitude: decibels, color: .gray))
    }

    return result
  }
}
