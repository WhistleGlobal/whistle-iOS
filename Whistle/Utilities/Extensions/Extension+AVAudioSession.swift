//
//  AVAudioSession+Ext.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import AVFoundation

extension AVAudioSession {
  func playAndRecord() {
    print("Configuring playAndRecord session")
    do {
      try setCategory(.playAndRecord, mode: .default)
      try overrideOutputAudioPort(AVAudioSession.PortOverride.none)
      print("AVAudio Session out options: ", currentRoute)
      print("Successfully configured audio session.")
    } catch {
      print("Error while configuring audio session: \(error)")
    }
  }

  func configureRecordAudioSessionCategory() {
    print("Configuring record session")
    do {
      try setCategory(.record, mode: .default)
      try overrideOutputAudioPort(AVAudioSession.PortOverride.none)
      print("AVAudio Session out options: ", currentRoute)
      print("Successfully configured audio session.")
    } catch {
      print("Error while configuring audio session: \(error)")
    }
  }

  func configurePlaybackSession() {
//    print("Configuring playback session")
    do {
      try setCategory(.playback, mode: .default)
      try overrideOutputAudioPort(.none)
      try setActive(true)
//      print("Current audio route: ", currentRoute.outputs)
    } catch let error as NSError {
      print("#configureAudioSessionToSpeaker Error \(error.localizedDescription)")
    }
  }
}
