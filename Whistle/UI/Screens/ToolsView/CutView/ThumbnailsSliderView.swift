//
//  ThumbnailsSliderView.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import AVKit
import SwiftUI

// MARK: - ThumbnailsSliderView

struct ThumbnailsSliderView: View {
  @State var rangeDuration: ClosedRange<Double> = 0 ... 1
  @Binding var currentTime: Double
  @Binding var video: EditableVideo?
  @ObservedObject var editorVM: EditorViewModel
  @ObservedObject var videoPlayer: VideoPlayerManager

  let onChangeTimeValue: () -> Void

  var body: some View {
//    Group {
    GeometryReader { proxy in
      ZStack {
        thumbnailsImagesSection(proxy)
        if let video {
          RangedSliderView(
            editor: editorVM,
            player: videoPlayer,
            value: $rangeDuration,
            currentTime: $currentTime,
            bounds: 0 ... video.originalDuration,
            onEndChange: { setOnChangeTrim(false) })
            .onChange(of: self.video?.rangeDuration.upperBound) { upperBound in
              if let upperBound {
                currentTime = Double(upperBound)
                onChangeTimeValue()
                setOnChangeTrim(true)
              }
            }
            .onChange(of: self.video?.rangeDuration.lowerBound) { lowerBound in
              if let lowerBound {
                currentTime = Double(lowerBound)
                onChangeTimeValue()
                setOnChangeTrim(true)
              }
            }
            .onChange(of: rangeDuration) { newValue in
              self.video?.rangeDuration = newValue
            }
            .onAppear {
              setVideoRange()
            }
        }
      }
      .frame(width: proxy.size.width, height: proxy.size.height)
    }
    .frame(width: UIScreen.width - 48, height: UIScreen.getHeight(72))
    .hCenter()
    .padding(.vertical, 28)
    .background(Color.Elevated_Dark)
//    }
//    .frame(width: UIScreen.width)
  }
}

//// MARK: - ThumbnailsSliderView_Previews
//
// struct ThumbnailsSliderView_Previews: PreviewProvider {
//  static var previews: some View {
//    ThumbnailsSliderView(
//      currentTime: .constant(0),
//      video: .constant(EditableVideo.mock),
//      onChangeTimeValue: { }, videoPlayer: VideoPlayerManager)
//  }
// }

extension ThumbnailsSliderView {
  private func setVideoRange() {
    if let video {
      if video.rangeDuration.upperBound <= 15 {
        rangeDuration = video.rangeDuration
      } else {
        rangeDuration = video.rangeDuration.lowerBound ... 15
      }
      videoPlayer.currentTime = rangeDuration.lowerBound
    }
  }

  @ViewBuilder
  private func thumbnailsImagesSection(_ proxy: GeometryProxy) -> some View {
    if let video {
      ScrollView(.horizontal) {
        HStack(spacing: 0) {
          ForEach(video.thumbnailsImages) { trimData in
            if let image = trimData.image {
              Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: proxy.size.width / CGFloat(video.thumbnailsImages.count), height: proxy.size.height - 8)
                .clipped()
            }
          }
        }
      }
    }
  }

  /// 자르기에 변화가 생겼을 때 비디오 현재 재생 시간을 바꿔주는 함수.
  /// - Parameter isChange: 변화 생김
  private func setOnChangeTrim(_ isChange: Bool) {
    if !isChange {
      currentTime = video?.rangeDuration.lowerBound ?? 0
      onChangeTimeValue()
    }
  }
}
