//
//  Extension+AVAudioSession.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import AVFoundation

extension AVAudioSession {
  func playAndRecord() {
    do {
      try setCategory(.playAndRecord, mode: .default)
      try overrideOutputAudioPort(AVAudioSession.PortOverride.none)
    } catch {
      WhistleLogger.logger.debug("Error while configuring audio session: \(error)")
    }
  }

  func configureRecordAudioSessionCategory() {
    do {
      try setCategory(.record, mode: .default)
      try overrideOutputAudioPort(AVAudioSession.PortOverride.none)
    } catch {
      WhistleLogger.logger.debug("Error while configuring audio session: \(error)")
    }
  }

  func configurePlaybackSession() {
    do {
      try setCategory(.playback, mode: .default)
      try overrideOutputAudioPort(.none)
      try setActive(true)
    } catch let error as NSError {
      print("#configureAudioSessionToSpeaker Error \(error.localizedDescription)")
    }
  }
}
