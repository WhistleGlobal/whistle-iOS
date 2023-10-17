//
//  PhotoEditorContentView+Brush.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/29.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit

// MARK: - PhotoEditorContentView + CanvasDelegate

extension PhotoEditorContentView: CanvasDelegate {
  func canvasDidBeginDraw() {
    context.action(.brushBeginDraw)
  }

  func canvasDidEndDraw() {
    context.action(.brushFinishDraw(canvas.drawnPaths.map { BrushData(drawnPath: $0) }))
  }
}

// MARK: - PhotoEditorContentView + CanvasDataSource

extension PhotoEditorContentView: CanvasDataSource {
  func canvasGetLineWidth(_: Canvas) -> CGFloat {
    let scale = scrollView.zoomScale
    return options.brushWidth / scale
  }
}
