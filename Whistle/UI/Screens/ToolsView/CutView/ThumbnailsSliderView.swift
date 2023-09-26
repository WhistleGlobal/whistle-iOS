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
  @Binding var curretTime: Double
  @Binding var video: EditableVideo?
  var isChangeState: Bool?
  let onChangeTimeValue: () -> Void

  private var totalDuration: Double {
    rangeDuration.upperBound - rangeDuration.lowerBound
  }

  var body: some View {
    VStack(spacing: 6) {
      // 자르기 범위 안에 들어간 초
      Text(totalDuration.formatterTimeString())
        .foregroundColor(.white)
        .font(.subheadline)
      GeometryReader { proxy in
        ZStack {
          thumbnailsImagesSection(proxy)
            .border(Color.red, width: 2)
          if let video {
            RangedSliderView(
              value: $rangeDuration,
              bounds: 0 ... video.originalDuration,
              onEndChange: { setOnChangeTrim(false) })
            {
              Rectangle().blendMode(.destinationOut)
            }
            .onChange(of: self.video?.rangeDuration.upperBound) { upperBound in
              if let upperBound {
                curretTime = Double(upperBound)
                onChangeTimeValue()
                setOnChangeTrim(true)
              }
            }
            .onChange(of: self.video?.rangeDuration.lowerBound) { lowerBound in
              if let lowerBound {
                curretTime = Double(lowerBound)
                onChangeTimeValue()
                setOnChangeTrim(true)
              }
            }
            .onChange(of: rangeDuration) { newValue in
              self.video?.rangeDuration = newValue
            }
          }
        }
        .frame(width: proxy.size.width, height: proxy.size.height)
        .onAppear {
          setVideoRange()
        }
      }
      .frame(width: getRect().width - 64, height: 70)
    }
    .onChange(of: isChangeState) { isChange in
      if !(isChange ?? true) {
        setVideoRange()
      }
    }
  }
}

// MARK: - ThumbnailsSliderView_Previews

struct ThumbnailsSliderView_Previews: PreviewProvider {
  static var previews: some View {
    ThumbnailsSliderView(
      curretTime: .constant(0),
      video: .constant(EditableVideo.mock),
      isChangeState: nil,
      onChangeTimeValue: { })
  }
}

extension ThumbnailsSliderView {
  private func setVideoRange() {
    if let video {
      rangeDuration = video.rangeDuration
    }
  }

  @ViewBuilder
  private func thumbnailsImagesSection(_ proxy: GeometryProxy) -> some View {
    if let video {
      HStack(spacing: 0) {
        ForEach(video.thumbnailsImages) { trimData in
          if let image = trimData.image {
            Image(uiImage: image)
              .resizable()
              .aspectRatio(contentMode: .fit)
              .rotationEffect(Angle(degrees: 90))
              .frame(width: proxy.size.width / CGFloat(video.thumbnailsImages.count), height: proxy.size.height - 5)
              .clipped()
          }
        }
      }
    }
  }

  private func setOnChangeTrim(_ isChange: Bool) {
    if !isChange {
      curretTime = video?.rangeDuration.upperBound ?? 0
      onChangeTimeValue()
    }
  }
}
