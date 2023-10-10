//
//  UploadView.swift
//  Whistle
//
//  Created by 박상원 on 10/9/23.
//

import Combine
import SwiftUI

struct UploadView: View {
  private enum Field: Int, CaseIterable {
    case content, hashtag
  }

  @Environment(\.dismiss) private var dismiss
  @StateObject var apiViewModel = APIViewModel()
  @ObservedObject var editorVM: EditorViewModel
  @ObservedObject var videoPlayer: VideoPlayerManager
  @FocusState private var focusedField: Field?
  @State var content = ""
  let videoScale: CGFloat = 16 / 9
  let videoWidth: CGFloat = 203
  let textLimit = 40

  var body: some View {
    ZStack {
      Color.white.ignoresSafeArea()
        .onTapGesture {
          focusedField = nil
        }
      VStack {
        CustomNavigationBarViewController(title: "새 게시물") {
          dismiss()
        } nextButtonAction: { }
          .frame(height: UIScreen.getHeight(44))
        EditablePlayerView(player: videoPlayer.videoPlayer)
          .frame(width: UIScreen.getWidth(videoWidth), height: UIScreen.getHeight(videoWidth * videoScale))
          .cornerRadius(12)
          .hCenter()
          .vCenter()
        TextField(text: $content, axis: .vertical) {
          Text("내용을 입력해 주세요. (40자 내)")
        }
        .onReceive(Just(content)) { _ in
          limitText(textLimit)
        }
        .frame(height: UIScreen.getHeight(160), alignment: .topLeading)
        .contentShape(Rectangle())
        .onTapGesture {
          focusedField = .content
        }
        .padding(UIScreen.getWidth(16))
        .focused($focusedField, equals: .content)
        .background(
          RoundedRectangle(cornerRadius: 8)
            .strokeBorder(Color.Border_Default))
        .padding(.horizontal, UIScreen.getWidth(16))
//        Button {
//          apiViewModel.uploadPost(video: String, thumbnail: String, caption: String, musicID: Int, videoLength: Double, hashtags: [String]) {
//
//          }
//        } label: {
//          Text("완료")
//            .padding(.vertical, 10)
//            .padding(.horizontal, 100)
//            .background(Color.Blue_Default)
//        }
      }
    }
    .toolbar(.hidden)
  }

  func limitText(_ upper: Int) {
    if content.count > upper {
      content = String(content.prefix(upper))
    }
  }
}

#Preview {
  UploadView(editorVM: EditorViewModel(), videoPlayer: VideoPlayerManager())
}
