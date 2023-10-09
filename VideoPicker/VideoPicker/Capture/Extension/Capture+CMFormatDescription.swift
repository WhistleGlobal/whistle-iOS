//
//  Capture+CMFormatDescription.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/12/27.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import CoreMedia

extension CMAudioFormatDescription {

  var streamBasicDescription: AudioStreamBasicDescription? {
    CMAudioFormatDescriptionGetStreamBasicDescription(self)?.pointee
  }
}

extension CMVideoFormatDescription {

  var dimensions: CMVideoDimensions {
    CMVideoFormatDescriptionGetDimensions(self)
  }
}
