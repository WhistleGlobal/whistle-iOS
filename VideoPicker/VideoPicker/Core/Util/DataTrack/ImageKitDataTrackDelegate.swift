//
//  ImageKitDataTrackDelegate.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/10/16.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import Foundation

// MARK: - ImageKitDataTrackDelegate

public protocol ImageKitDataTrackDelegate: AnyObject {
  func dataTrack(page: AnyImagePage, state: AnyImagePageState)
  func dataTrack(event: AnyImageEvent, userInfo: [AnyImageEventUserInfoKey: Any])
}

extension ImageKitDataTrackDelegate {
  func dataTrack(page _: AnyImagePage, state _: AnyImagePageState) { }
  func dataTrack(event _: AnyImageEvent, userInfo _: [AnyImageEventUserInfoKey: Any]) { }
}
