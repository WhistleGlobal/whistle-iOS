//
//  TimeLineView.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import SwiftUI

// MARK: - TimeLineView

struct TimeLineView: View {
  @State private var textTimeInterval: ClosedRange<Double> = 0 ... 1
  @Binding var currentTime: Double
  @Binding var isSelectedTrack: Bool
  var viewState: TimeLineViewState = .empty
  var video: EditableVideo
  var textInterval: ClosedRange<Double>?
  let onChangeTimeValue: () -> Void
  let onSetAudio: (Audio) -> Void
  private let frameWidth: CGFloat = 46

  private var calcWidth: CGFloat {
    frameWidth * CGFloat(viewState.countImages) + 10
  }

  var body: some View {
    ZStack {
      if !video.thumbnailsImages.isEmpty {
        TimelineSlider(bounds: video.rangeDuration, value: $currentTime, frameWidth: calcWidth) {
          // MARK: - frameView

          VStack(alignment: .leading, spacing: 5) {
            ZStack {
              tubnailsImages(video.thumbnailsImages)
            }
          }

        } onChange: {
          onChangeTimeValue()
        }
      }
    }
    .frame(height: viewState.height)
    .onChange(of: textTimeInterval.lowerBound) { newValue in
      currentTime = newValue
      onChangeTimeValue()
    }
    .onChange(of: textTimeInterval.upperBound) { newValue in
      currentTime = newValue
      onChangeTimeValue()
    }
    .onChange(of: textInterval) { newValue in
      if let newValue {
        textTimeInterval = newValue
      }
    }
    .onChange(of: viewState) { newValue in
      if newValue == .empty {
        currentTime = 0
        onChangeTimeValue()
      }
    }
  }
}

// MARK: - TimeLineView_Previews

struct TimeLineView_Previews: PreviewProvider {
  static var video: EditableVideo {
    var video = EditableVideo.mock
    video.thumbnailsImages = [.init(image: UIImage(systemName: "person")!)]
    return video
  }

  static var previews: some View {
    ZStack {
      Color.secondary
      TimeLineView(
        currentTime: .constant(0),
        isSelectedTrack: .constant(true),
        viewState: .audio,
        video: video,
        onChangeTimeValue: { },
        onSetAudio: { _ in })
    }
  }
}

extension TimeLineView {
  private func tubnailsImages(_ images: [ThumbnailImage]) -> some View {
//    let images = firstAndAverageImage(images)
    let images = images
    return HStack(spacing: 0) {
      ForEach(images) { image in
        if let image = image.image {
          Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 52)
            .rotationEffect(Angle(degrees: 90))
            .clipped()
        }
      }
    }
    .overlay {
      if viewState == .audio {
        if isSelectedTrack {
          RoundedRectangle(cornerRadius: 5)
            .strokeBorder(lineWidth: 2)
            .foregroundColor(.white)
        }
        HStack(spacing: 1) {
          if video.volume > 0 {
            Image(systemName: "speaker.wave.2.fill")
            Text(verbatim: String(Int(video.volume * 100)))
          } else {
            Image(systemName: "speaker.slash.fill")
          }
        }
        .font(.system(size: 9))
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        .padding(5)
      }
    }
    .onTapGesture {
      if viewState == .audio, !isSelectedTrack {
        isSelectedTrack.toggle()
        currentTime = 0
        onChangeTimeValue()
      }
    }
  }

  private func firstAndAverageImage(_ images: [ThumbnailImage]) -> [ThumbnailImage] {
    guard let first = images.first else { return [] }

    var newArray = [first]

    if viewState == .audio {
      let averageIndex = Int(images.count / 2)
      newArray.append(images[averageIndex])
    }

    return newArray
  }
}

// MARK: - TimeLineViewState

enum TimeLineViewState: Int {
  case audio, empty

  var width: CGFloat {
    switch self {
    case .audio: return 40
    case .empty: return 10
    }
  }

  var height: CGFloat {
    switch self {
    case .audio: return 110
    case .empty: return 60
    }
  }

  var countImages: Int {
    switch self {
    case .audio: return 2
    case .empty: return 8
    }
  }
}
