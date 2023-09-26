//
//  Capture+CMSampleBuffer.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/12/27.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import CoreMedia

extension CMSampleBuffer {

  var presentationTimeStamp: CMTime {
    CMSampleBufferGetPresentationTimeStamp(self)
  }

  var formatDescription: CMFormatDescription? {
    CMSampleBufferGetFormatDescription(self)
  }

  var imageBuffer: CVImageBuffer? {
    CMSampleBufferGetImageBuffer(self)
  }
}
