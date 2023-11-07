//
//  SingleContentView.swift
//  Whistle
//
//  Created by ChoiYujin on 11/6/23.
//

import AVFoundation
import BottomSheet
import Kingfisher
import SwiftUI

// MARK: - SingleContentView

struct SingleContentView: View {

  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject var tabbarModel = TabbarModel.shared
  @StateObject private var toastViewModel = ToastViewModel.shared
  @StateObject var bartintModel = BarTintModel.shared
  @State var showPlayButton = false
  @State var bottomSheetPosition: BottomSheetPosition = .hidden
  @State var timer: Timer? = nil
  @State var player: AVPlayer?
  let contentID: Int

  var body: some View {
    ZStack {
      if let player {
        Color.black.overlay {
          if let url = apiViewModel.singleContent.thumbnailUrl {
            KFImage.url(URL(string: url))
              .placeholder {
                Color.black
                  .frame(maxWidth: .infinity, maxHeight: .infinity)
              }
              .resizable()
              .aspectRatio(
                contentMode: apiViewModel.singleContent.aspectRatio ?? 1.0 > Double(15.0 / 9.0) ? .fill : .fit)
              .frame(maxWidth: .infinity, maxHeight: .infinity)
          }
          ContentPlayer(player: player, aspectRatio: apiViewModel.singleContent.aspectRatio)
            .frame(width: UIScreen.width, height: UIScreen.height)
            .onTapGesture(count: 2) {
              whistleToggle(content: apiViewModel.singleContent)
            }
            .onTapGesture {
              if player.rate == 0.0 {
                player.play()
                showPlayButton = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                  withAnimation {
                    showPlayButton = false
                  }
                }
              } else {
                player.pause()
                showPlayButton = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                  withAnimation {
                    showPlayButton = false
                  }
                }
              }
            }
            .onLongPressGesture {
              HapticManager.instance.impact(style: .medium)
              bottomSheetPosition = .absolute(186)
            }
            .overlay {
              ContentGradientLayer()
                .allowsHitTesting(false)
              if tabbarModel.tabWidth != 56 {
                SingleContentLayer(
                  currentVideoInfo: apiViewModel.singleContent,
                  bottomSheetPosition: $bottomSheetPosition)
                  .padding(.bottom, UIScreen.main.nativeBounds.height == 1334 ? 24 : 0)
              }
              if bottomSheetPosition != .hidden {
                DimsThick()
              }
            }
          playButton(toPlay: player.rate == 0)
            .opacity(showPlayButton ? 1 : 0)
            .allowsHitTesting(false)

          if BlockList.shared.userIds.contains(apiViewModel.singleContent.userId ?? 0) {
            KFImage.url(URL(string: apiViewModel.singleContent.thumbnailUrl ?? ""))
              .placeholder {
                Color.black
              }
              .resizable()
              .scaledToFill()
              .blur(radius: 30)
              .overlay {
                VStack {
                  Image(systemName: "eye.slash.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.Gray10)
                    .padding(.bottom, 26)
                  Text("차단된 계정의 콘텐츠입니다.")
                    .fontSystem(fontDesignSystem: .subtitle1)
                    .foregroundColor(.LabelColor_Primary_Dark)
                    .padding(.bottom, 12)
                  Text("차단된 계정의 모든 콘텐츠는 \n회원님의 피드에 노출되지 않습니다.")
                    .fontSystem(fontDesignSystem: .body2)
                    .foregroundColor(.LabelColor_Secondary_Dark)
                    .multilineTextAlignment(.center)
                }
              }
          }
        }
        .ignoresSafeArea()
      } else {
        VStack {
          Spacer()
          Image(systemName: "photo")
            .resizable()
            .scaledToFit()
            .frame(width: 60)
            .foregroundColor(.LabelColor_Primary_Dark)
          Text("콘텐츠가 없습니다")
            .fontSystem(fontDesignSystem: .body1)
            .foregroundColor(.LabelColor_Primary_Dark)
            .frame(maxWidth: .infinity, alignment: .center)
          Spacer()
        }
        .ignoresSafeArea()
        .background(.black)
      }
    }
    .task {
      await apiViewModel.requestSingleContent(contentID: contentID)
      guard let videoUrl = apiViewModel.singleContent.videoUrl else {
        return
      }
      player = AVPlayer(url: URL(string: videoUrl)!)
      await player?.seek(to: .zero)
      player?.play()
    }
    .toolbarRole(.editor)
    .onAppear {
      bartintModel.tintColor = .white
    }
    .onDisappear {
      bartintModel.tintColor = .LabelColor_Primary
      player?.pause()
    }
    .bottomSheet(
      bottomSheetPosition: $bottomSheetPosition,
      switchablePositions: [.hidden, .absolute(186)])
    {
      VStack(spacing: 0) {
        HStack {
          Color.clear.frame(width: 28)
          Spacer()
          Text(CommonWords().more)
            .fontSystem(fontDesignSystem: .subtitle1)
            .foregroundColor(.white)
          Spacer()
          Button {
            bottomSheetPosition = .hidden
          } label: {
            Text(CommonWords().cancel)
              .fontSystem(fontDesignSystem: .subtitle2)
              .foregroundColor(.white)
          }
        }
        .frame(height: 24)
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        Rectangle().frame(width: UIScreen.width, height: 1).foregroundColor(Color.Border_Default_Dark)
        Button {
          bottomSheetPosition = .hidden
          toastViewModel.cancelToastInit(message: "삭제되었습니다") {
            Task {
              await apiViewModel.deleteContent(contentID: contentID)
              apiViewModel.singleContent = .init()
              player?.pause()
              player = nil
            }
          }
        } label: {
          bottomSheetRowWithIcon(systemName: "trash", text: "삭제하기")
        }
        Spacer()
      }
      .frame(height: 186)
    }
    .enableSwipeToDismiss(true)
    .enableTapToDismiss(true)
    .enableContentDrag(true)
    .enableAppleScrollBehavior(false)
    .dragIndicatorColor(Color.Border_Default_Dark)
    .customBackground(
      glassMorphicView(cornerRadius: 24)
        .overlay {
          RoundedRectangle(cornerRadius: 24)
            .stroke(lineWidth: 1)
            .foregroundStyle(
              LinearGradient.Border_Glass)
        })
    .onDismiss {
      tabbarModel.tabbarOpacity = 1.0
    }
    .onChange(of: bottomSheetPosition) { newValue in
      if newValue == .hidden {
        tabbarModel.tabbarOpacity = 1.0
      } else {
        tabbarModel.tabbarOpacity = 0.0
      }
    }
  }
}

extension SingleContentView {
  func whistleToggle(content: MainContent) {
    HapticManager.instance.impact(style: .medium)
    timer?.invalidate()
    if apiViewModel.singleContent.isWhistled {
      timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
        Task {
          await apiViewModel.whistleAction(contentID: content.contentId ?? 0, method: .delete)
        }
      }
      apiViewModel.singleContent.whistleCount -= 1
    } else {
      timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
        Task {
          await apiViewModel.whistleAction(contentID: content.contentId ?? 0, method: .post)
        }
      }
      apiViewModel.singleContent.whistleCount += 1
    }
    apiViewModel.singleContent.isWhistled.toggle()
  }
}
