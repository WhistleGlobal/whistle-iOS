//
//  MyContentListView.swift
//  Whistle
//
//  Created by ChoiYujin on 9/20/23.
//

import AVFoundation
import Kingfisher
import SwiftUI

// MARK: - MyContentListView

struct MyContentListView: View {

  @Environment(\.dismiss) var dismiss
  @State var currentIndex = 0
  @State var newId = UUID()
  @State var playerIndex = 0
  @EnvironmentObject var apiViewModel: APIViewModel
  @State var players: [AVPlayer?] = []
  @Binding var tabSelection: TabSelection
  @Binding var tabbarOpacity: Double
  @Binding var tabWidth: CGFloat

  var body: some View {
    GeometryReader { proxy in
      TabView(selection: $currentIndex) {
        ForEach(Array(apiViewModel.myPostFeed.enumerated()), id: \.element) { index, content in
          if !players.isEmpty {
            if let player = players[index] {
              Player(player: player)
                .frame(width: proxy.size.width)
                .overlay {
                  // TODO: - contentId 백엔드 수정 필요, contentId & whistleCount
                  userInfo(
                    contentId: 0,
                    caption: content.caption ?? "",
                    musicTitle: content.musicTitle ?? "",
                    isWhistled:
                    Binding(get: {
                      content.isWhistled == 1 ? true : false
                    }, set: { newValue in
                      content.isWhistled = newValue ? 1 : 0
                    }),
                    whistleCount:
                    Binding(get: {
                      0
                    }, set: { _ in
                      0
                    }))
                }
                .padding()
                .rotationEffect(Angle(degrees: -90))
                .ignoresSafeArea(.all, edges: .top)

                .tag(index)
            } else {
              KFImage.url(URL(string: content.thumbnailUrl ?? ""))
                .placeholder {
                  Color.black
                }
                .resizable()
                .scaledToFill()
                .tag(index)
                .frame(width: proxy.size.width)
                .padding()
                .rotationEffect(Angle(degrees: -90))
                .ignoresSafeArea(.all, edges: .top)
            }
          }
        }
        .onReceive(apiViewModel.publisher) { id in
          newId = id
        }
        .id(newId)
      }
      .rotationEffect(Angle(degrees: 90))
      .frame(width: proxy.size.height)
      .tabViewStyle(.page(indexDisplayMode: .never))
      .frame(maxWidth: proxy.size.width)
    }
    .ignoresSafeArea(.all, edges: .top)
    .background(.black)
    .onAppear {
      players.append(AVPlayer(url: URL(string: apiViewModel.myPostFeed[currentIndex].videoUrl ?? "")!))
      for _ in 0..<apiViewModel.myPostFeed.count - 1 {
        players.append(nil)
      }
      guard let player = players[currentIndex] else {
        return
      }
      player.seek(to: .zero)
      player.play()
    }
    .onChange(of: currentIndex) { newValue in
      log(playerIndex)
      log(newValue)
      log(currentIndex)
      guard let url = apiViewModel.myPostFeed[newValue].videoUrl else {
        return
      }
      players[newValue] = AVPlayer(url: URL(string: url)!)
      players[playerIndex]?.seek(to: .zero)
      players[playerIndex]?.pause()
      players[playerIndex] = nil
      players[newValue]?.seek(to: .zero)
      players[newValue]?.play()
      playerIndex = newValue
      apiViewModel.postFeedPlayerChanged()
    }
    .overlay {
      VStack {
        Spacer()
        glassMorphicTab(width: tabWidth)
          .overlay {
            if tabWidth != 56 {
              tabItems()
            } else {
              HStack(spacing: 0) {
                Spacer().frame(minWidth: 0)
                Button {
                  withAnimation {
                    tabWidth = UIScreen.width - 32
                  }
                } label: {
                  Circle()
                    .foregroundColor(.Dim_Default)
                    .frame(width: 48, height: 48)
                    .overlay {
                      Circle()
                        .stroke(lineWidth: 1)
                        .foregroundStyle(LinearGradient.Border_Glass)
                    }
                    .padding(4)
                    .overlay {
                      Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .foregroundColor(.White)
                        .frame(width: 20, height: 20)
                    }
                }
              }
            }
          }
          .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
              .onEnded { value in
                if value.translation.width > 50 {
                  log("right swipe")
                  withAnimation {
                    tabWidth = 56
                  }
                }
              })
      }
      .padding(.horizontal, 16)
      .opacity(tabbarOpacity)
    }
  }
}

extension MyContentListView {

  @ViewBuilder
  func userInfo(
    contentId: Int,
    caption: String,
    musicTitle: String,
    isWhistled: Binding<Bool>,
    whistleCount: Binding<Int>)
    -> some View
  {
    VStack(spacing: 0) {
      Spacer()
      HStack(spacing: 0) {
        VStack(alignment: .leading, spacing: 12) {
          Spacer()
          HStack(spacing: 0) {
            Group {
              profileImageView(url: apiViewModel.myProfile.profileImage, size: 36)
                .padding(.trailing, 12)
              Text(apiViewModel.myProfile.userName)
                .foregroundColor(.white)
                .fontSystem(fontDesignSystem: .subtitle1)
                .padding(.trailing, 16)
            }
          }
          HStack(spacing: 0) {
            Text(caption)
              .fontSystem(fontDesignSystem: .body2_KO)
              .foregroundColor(.white)
          }
          Label(musicTitle, systemImage: "music.note")
            .fontSystem(fontDesignSystem: .body2_KO)
            .foregroundColor(.white)
        }
        Spacer()
        VStack(spacing: 0) {
          Spacer()
          Button {
            Task {
              if isWhistled.wrappedValue {
                await apiViewModel.actionWhistleCancel(contentId: contentId)
                whistleCount.wrappedValue -= 1
              } else {
                await apiViewModel.actionWhistle(contentId: contentId)
                whistleCount.wrappedValue += 1
              }
              isWhistled.wrappedValue.toggle()
              apiViewModel.postFeedPlayerChanged()
            }
          } label: {
            VStack(spacing: 0) {
              Image(systemName: isWhistled.wrappedValue ? "heart.fill" : "heart")
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 26)
                .foregroundColor(.Gray10)
                .padding(.bottom, 2)
              Text("\(whistleCount.wrappedValue)")
                .foregroundColor(.Gray10)
                .fontSystem(fontDesignSystem: .caption_Regular)
                .padding(.bottom, 24)
            }
          }
          Button {
//               showPasteToast = true
            UIPasteboard.general.setValue(
              "복사할 링크입니다.",
              forPasteboardType: UTType.plainText.identifier)
          } label: {
            Image(systemName: "square.and.arrow.up")
              .resizable()
              .scaledToFit()
              .frame(width: 25, height: 32)
              .foregroundColor(.Gray10)
              .padding(.bottom, 24)
          }
          .fontSystem(fontDesignSystem: .caption_Regular)
          Button {
//               showDialog = true
          } label: {
            Image(systemName: "ellipsis")
              .resizable()
              .scaledToFit()
              .frame(width: 30, height: 25)
              .foregroundColor(.Gray10)
          }
        }
      }
    }
    .padding(.bottom, 112)
    .padding(.horizontal, 20)
  }

  @ViewBuilder
  func tabItems() -> some View {
    RoundedRectangle(cornerRadius: 100)
      .foregroundColor(Color.Dim_Default)
      .frame(width: (UIScreen.width - 32) / 3 - 6)
      .offset(x: tabSelection.rawValue * ((UIScreen.width - 32) / 3))
      .padding(3)
      .overlay(
        Capsule()
          .stroke(lineWidth: 1)
          .foregroundStyle(LinearGradient.Border_Glass)
          .padding(3)
          .offset(x: tabSelection.rawValue * ((UIScreen.width - 32) / 3)))
      .foregroundColor(.clear)
      .frame(height: 56)
      .frame(maxWidth: .infinity)
      .overlay {
        Button {
          Task {
            dismiss()
            withAnimation {
              self.tabSelection = .main
            }
          }
        } label: {
          Color.clear.overlay {
            Image(systemName: "house.fill")
              .resizable()
              .scaledToFit()
              .frame(width: 24, height: 24)
          }
          .frame(width: (UIScreen.width - 32) / 3, height: 56)
        }
        .foregroundColor(.white)
        .padding(3)
        .offset(x: -1 * ((UIScreen.width - 32) / 3))

        Button {
          dismiss()
          withAnimation {
            self.tabSelection = .upload
          }

        } label: {
          Color.clear.overlay {
            Image(systemName: "plus")
              .resizable()
              .scaledToFit()
              .frame(width: 20, height: 20)
              .foregroundColor(.white)
          }
          .frame(width: (UIScreen.width - 32) / 3, height: 56)
        }
        .foregroundColor(.white)
        .padding(3)
        Button {
          dismiss()
        } label: {
          Color.clear.overlay {
            Image(systemName: "person.fill")
              .resizable()
              .scaledToFit()
              .frame(width: 20, height: 20)
              .foregroundColor(.white)
          }
          .frame(width: (UIScreen.width - 32) / 3, height: 56)
        }
        .foregroundColor(.white)
        .padding(3)
        .offset(x: (UIScreen.width - 32) / 3)
      }
      .frame(height: 56)
      .frame(maxWidth: .infinity)
  }

}
