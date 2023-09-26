//
//  ToolsSectionView.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import AVKit
import SwiftUI

// MARK: - ToolsSectionView

struct ToolsSectionView: View {
  @StateObject var filtersVM = FiltersViewModel()
  @ObservedObject var videoPlayer: VideoPlayerManager
  @ObservedObject var editorVM: EditorViewModel
  private let columns = Array(repeating: GridItem(.flexible()), count: 4)
  var body: some View {
    ZStack {
      ScrollView(.horizontal, showsIndicators: false) {
        HStack {
          ForEach(ToolEnum.allCases, id: \.self) { tool in
            ToolButtonView(
              label: tool.title,
              image: tool.image,
              isChange: editorVM.currentVideo?.isAppliedTool(for: tool) ?? false)
            {
              editorVM.selectedTools = tool
            }
          }
        }
      }
      .padding()
      .opacity(editorVM.selectedTools != nil ? 0 : 1)
      if let toolState = editorVM.selectedTools, let video = editorVM.currentVideo {
        bottomSheet(toolState, video)
          .transition(.move(edge: .bottom).combined(with: .opacity))
      }
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

struct ToolsSectionView_Previews: PreviewProvider {
  static var previews: some View {
    MainEditorView(selectedVideoURl: EditableVideo.mock.url)
  }
}

extension ToolsSectionView {
  @ViewBuilder
  private func bottomSheet(_ tool: ToolEnum, _ video: EditableVideo) -> some View {
    let isAppliedTool = video.isAppliedTool(for: tool)

    VStack(spacing: 16) {
      sheetHeader(tool)
      switch tool {
      case .cut:
        ThumbnailsSliderView(
          curretTime: $videoPlayer.currentTime,
          video: $editorVM.currentVideo,
          isChangeState: isAppliedTool)
        {
          videoPlayer.scrubState = .scrubEnded(videoPlayer.currentTime)
          editorVM.setTools()
        }
      case .speed:
        VideoSpeedSlider(value: Double(video.rate), isChangeState: isAppliedTool) { rate in
          videoPlayer.pause()
          editorVM.updateRate(rate: rate)
        }
      case .audio:
        AudioSheetView(videoPlayer: videoPlayer, editorVM: editorVM)
      case .filters:
        FiltersView(selectedFilterName: video.filterName, viewModel: filtersVM) { filterName in
          if let filterName {
            videoPlayer.setFilters(mainFilter: CIFilter(name: filterName), colorCorrection: filtersVM.colorCorrection)
          } else {
            videoPlayer.removeFilter()
          }
          editorVM.setFilter(filterName)
        }
      case .corrections:
        CorrectionsToolView(correction: $filtersVM.colorCorrection) { corrections in
          videoPlayer.setFilters(mainFilter: CIFilter(name: video.filterName ?? ""), colorCorrection: corrections)
          editorVM.setCorrections(corrections)
        }
      case .frames:
        FramesToolView(
          selectedColor: $editorVM.frames.frameColor,
          scaleValue: $editorVM.frames.scaleValue,
          onChange: editorVM.setFrames)
      }
      Spacer()
    }
    .padding([.horizontal, .top])
    .background(Color(.systemGray6))
  }
}

extension ToolsSectionView {
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
      if tool != .filters, tool != .audio {
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
