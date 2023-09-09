//
//  AudioService.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/05.
//
import AVFoundation
import Combine
import Foundation

// MARK: - ServiceProtocol

protocol ServiceProtocol {
  func buffer(url: URL, samplesCount: Int, completion: @escaping ([AudioPreviewModel]) -> Void)
}

// MARK: - Service

class Service {
  static let shared: ServiceProtocol = Service()
  private init() { }
}

// MARK: ServiceProtocol

extension Service: ServiceProtocol {
  func buffer(url: URL, samplesCount: Int, completion: @escaping ([AudioPreviewModel]) -> Void) {
    DispatchQueue.global(qos: .userInteractive).async {
      do {
        var cur_url = url
        if url.absoluteString.hasPrefix("https://") {
          let data = try Data(contentsOf: url)

          let directory = FileManager.default.temporaryDirectory
          let fileName = "chunk.m4a)"
          cur_url = directory.appendingPathComponent(fileName)

          try data.write(to: cur_url)
        }

        let file = try AVAudioFile(forReading: cur_url)
        if
          let format = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: file.fileFormat.sampleRate,
            channels: file.fileFormat.channelCount,
            interleaved: false),
          let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(file.length))
        {
          try file.read(into: buf)
          guard let floatChannelData = buf.floatChannelData else { return }
          let frameLength = Int(buf.frameLength)

          let samples = Array(UnsafeBufferPointer(start: floatChannelData[0], count: frameLength))
          //        let samples2 = Array(UnsafeBufferPointer(start:floatChannelData[1], count:frameLength))

          var result = [AudioPreviewModel]()

          let chunked = samples.chunked(into: samples.count / samplesCount)
          for (index, row) in chunked.enumerated() {
            var accumulator: Float = 0
            let newRow = row.map { $0 * $0 }
            accumulator = newRow.reduce(0, +)
            let power: Float = accumulator / Float(row.count)
            let decibles = 10 * log10f(power)

            result.append(AudioPreviewModel(index: index, magnitude: decibles, color: .gray))
          }

          DispatchQueue.main.async {
            completion(result)
          }
        }
      } catch {
        print("Audio Error: \(error)")
      }
    }
  }
}
