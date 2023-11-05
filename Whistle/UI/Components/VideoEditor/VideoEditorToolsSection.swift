//
//  VideoEditorToolsSection.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import AVKit
import SwiftUI

// MARK: - VideoEditorToolsSection

struct VideoEditorToolsSection: View {
  @StateObject var filtersVM = VideoFiltersViewModel()
  @ObservedObject var videoPlayer: VideoPlayerManager
  @ObservedObject var editorVM: VideoEditorViewModel

  private let columns = Array(repeating: GridItem(.flexible()), count: 4)

  var body: some View {
    ZStack {
//      ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 20) {
        ForEach(ToolEnum.allCases, id: \.self) { tool in
          EditorToolButton(
            label: tool.title,
            image: tool.image,
            isChange: editorVM.currentVideo?.isAppliedTool(for: tool) ?? false)
          {
            editorVM.selectedTools = tool
          }
        }
      }
//      }
      .padding(.horizontal, 16)
    }
    .animation(.easeIn(duration: 0.15), value: editorVM.selectedTools)
    .onChange(of: editorVM.currentVideo) { newValue in
      if let video = newValue, let image = video.thumbnailsImages.first?.image {
        filtersVM.loadFilters(for: image)
        filtersVM.colorCorrection = video.colorCorrection
      }
    }
  }
}

// MARK: - ToolsSectionView_Previews

extension VideoEditorToolsSection {
  @ViewBuilder
  private func bottomSheet(_ tool: ToolEnum, _: EditableVideo) -> some View {
    VStack(spacing: 16) {
      sheetHeader(tool)
      switch tool {
//      case .cut:
//        ThumbnailsSliderView(
//          currentTime: $videoPlayer.currentTime,
//          video: $editorVM.currentVideo,
//          editorVM: editorVM,
//          videoPlayer: videoPlayer)
//        {
//          videoPlayer.scrubState = .scrubEnded(videoPlayer.currentTime)
//          editorVM.setTools()
//        }
//      case .speed:
//        VideoSpeedSlider(value: Double(video.rate), isChangeState: isAppliedTool) { rate in
//          videoPlayer.pause()
//          editorVM.updateRate(rate: rate)
//        }
      case .music:
        MusicListView(
          musicVM: MusicViewModel(),
          editorVM: editorVM,
          bottomSheetPosition: .constant(.hidden), showMusicTrimView: .constant(false)) { }
      case .audio:
        VolumeSliderSheetView(videoPlayer: videoPlayer, editorVM: editorVM, musicVM: MusicViewModel()) { }
//      case .filters:
//        FiltersView(selectedFilterName: video.filterName, viewModel: filtersVM) { filterName in
//          if let filterName {
//            videoPlayer.setFilters(mainFilter: CIFilter(name: filterName), colorCorrection: filtersVM.colorCorrection)
//          } else {
//            videoPlayer.removeFilter()
//          }
//          editorVM.setFilter(filterName)
//        }
//      case .corrections:
//        CorrectionsToolView(correction: $filtersVM.colorCorrection) { corrections in
//          videoPlayer.setFilters(mainFilter: CIFilter(name: video.filterName ?? ""), colorCorrection: corrections)
//          editorVM.setCorrections(corrections)
//        }
//      case .frames:
//        FramesToolView(
//          selectedColor: $editorVM.frames.frameColor,
//          scaleValue: $editorVM.frames.scaleValue,
//          onChange: editorVM.setFrames)
      }
      Spacer()
    }
    .padding([.horizontal, .top])
    .background(Color(.systemGray6))
  }
}

extension VideoEditorToolsSection {
  private func sheetHeader(_ tool: ToolEnum) -> some View {
    HStack {
      Button {
        editorVM.selectedTools = nil
      } label: {
        Image(systemName: "chevron.down")
          .imageScale(.small)
          .foregroundColor(.white)
          .padding(10)
          .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 5))
      }
      Spacer()
//      if tool != .filters, tool != .audio {
      if tool != .audio {
        Button {
          editorVM.reset()
        } label: {
          Text("Reset")
            .font(.subheadline)
        }
        .buttonStyle(.plain)
      } else if !editorVM.isSelectVideo {
        Button {
          videoPlayer.pause()
          editorVM.removeAudio()
        } label: {
          Image(systemName: "trash.fill")
            .foregroundColor(.white)
        }
      }
    }
    .overlay {
      Text(tool.title)
        .font(.headline)
    }
  }
}
