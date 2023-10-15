//
//  ChangeMonitoringTuner.swift
//
//
//  Created by 이영빈 on 2023/06/28.
//

import AVFoundation
import Foundation

struct ChangeMonitoringTuner: AespaDeviceTuning {
  let needLock = true

  let enabled: Bool

  init(isSubjectAreaChangeMonitoringEnabled: Bool) {
    enabled = isSubjectAreaChangeMonitoringEnabled
  }

  func tune(_ device: some AespaCaptureDeviceRepresentable) throws {
    device.enableMonitoring(enabled)
  }
}
