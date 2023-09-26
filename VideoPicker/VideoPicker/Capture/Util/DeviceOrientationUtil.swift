//
//  DeviceOrientationUtil.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/12/25.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import CoreMotion

// MARK: - DeviceOrientationUtilDelegate

protocol DeviceOrientationUtilDelegate: AnyObject {

  func device(_ util: DeviceOrientationUtil, didUpdate orientation: DeviceOrientation)
}

// MARK: - DeviceOrientationUtil

final class DeviceOrientationUtil {

  weak var delegate: DeviceOrientationUtilDelegate?

  private lazy var motionManager: CMMotionManager = {
    let manager = CMMotionManager()
    manager.accelerometerUpdateInterval = 0.2
    return manager
  }()

  private lazy var queue = OperationQueue()

  private(set) var orientation: DeviceOrientation = .portrait

  func startRunning() {
    let motionLimit = 0.6
    motionManager.startAccelerometerUpdates(to: queue) { [weak self] data, _ in
      guard let self else { return }
      guard let data else { return }
      let newOrientation: DeviceOrientation
      if data.acceleration.x >= motionLimit {
        newOrientation = .landscapeRight
      } else if data.acceleration.x <= -motionLimit {
        newOrientation = .landscapeLeft
      } else if data.acceleration.y <= -motionLimit {
        newOrientation = .portrait
      } else if data.acceleration.y >= motionLimit {
        newOrientation = .portraitUpsideDown
      } else {
        return
      }
      if newOrientation != orientation {
        orientation = newOrientation
        DispatchQueue.main.async { [weak self] in
          guard let self else { return }
          delegate?.device(self, didUpdate: newOrientation)
        }
      }
    }
  }

  func stopRunning() {
    motionManager.stopAccelerometerUpdates()
  }
}
