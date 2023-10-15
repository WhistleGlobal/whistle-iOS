//
//  MusicListView.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import Alamofire
import AVFoundation
import AVKit
import BottomSheet
import Kingfisher
import SwiftUI

// MARK: - DownloadStatus

enum DownloadStatus {
  case beforeDownload
  case inProgress
  case complete
  case playing
}

// MARK: - MusicListView

struct MusicListView: View {
  @ObservedObject var musicVM: MusicViewModel
  @ObservedObject var editorVM: EditorViewModel
  @ObservedObject var videoPlayer: VideoPlayerManager
  @Binding var bottomSheetPosition: BottomSheetPosition
  @Binding var showMusicTrimView: Bool
  @State var searchQueryString = ""
  @State var isSearching = false
  @State var musicList: [Music] = []
  @State var progressStatus: [Music: Double] = [:]
  @State var downloadStatus: [Music: DownloadStatus] = [:]
  @State var downloadRequests: [Music: DownloadRequest] = [:]
  @State var fileDirectories: [Music: URL] = [:]
  @State var audioPlayer: AVAudioPlayer?
  @State var currentMusic: Music? = nil {
    didSet(oldValue) {
      if let oldValue {
        downloadStatus[oldValue] = .complete
      }
    }
    willSet(newValue) {
      if let newValue {
        downloadStatus[newValue] = .playing
      }
    }
  }

  let tapSearchBar: (() -> Void)?
  var filteredMusicList: [Music] {
    if searchQueryString.isEmpty {
      return musicList
    } else {
      return musicList.filter { $0.musicTitle.localizedStandardContains(searchQueryString) }
    }
  }

  @StateObject var apiViewModel = APIViewModel()

  var body: some View {
    VStack {
      SearchBar(
        searchText: $searchQueryString,
        isSearching: $isSearching)
        .simultaneousGesture(TapGesture().onEnded {
          tapSearchBar?()
        })
      if musicList.isEmpty {
        ProgressView()
          .scaleEffect(2.0)
          .hCenter()
          .padding(.top, 40)
          .preferredColorScheme(.dark)
      } else {
        if !filteredMusicList.isEmpty {
          List(filteredMusicList, id: \.musicID) { music in
            HStack(spacing: 0) {
              KFImage(URL(string: music.albumCover))
                .cancelOnDisappear(true)
                .placeholder {
                  ProgressView()
                }
                .retry(maxCount: 3, interval: .seconds(0.5))
                .onSuccess { _ in
                }
                .onFailure { _ in
                }
                .resizable()
                .frame(width: UIScreen.getWidth(64), height: UIScreen.getWidth(64))
                .cornerRadius(8)
                .padding(.trailing, 16)
              HStack {
                Text("\(music.musicTitle)")
                Rectangle().foregroundStyle(.ultraThinMaterial.opacity(0.001))
              }
              .highPriorityGesture(TapGesture().onEnded {
                switch downloadStatus[music] {
                case .beforeDownload:
                  downloadAudioUsingAlamofire(for: music)
                default:
                  audioPlayer?.stop()
                  DispatchQueue.main.async {
                    musicVM.musicInfo = music
                    musicVM.url = fileDirectories[music]
                    Task {
                      if let url = musicVM.url, let duration = editorVM.currentVideo?.totalDuration {
                        musicVM.sample_count = Int(audioDuration(url) / (duration / 10))
                        musicVM.trimDuration = duration
                      }
                      await musicVM.visualizeAudio()
                      bottomSheetPosition = .hidden
                      editorVM.selectedTools = nil
                      showMusicTrimView = true
                    }
                  }
//                default: break
                }
              })
              handleDownloadButton(for: music)
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
          }
          .listStyle(.plain)
          .navigationTitle("")
          .foregroundStyle(Color.White)
        } else {
          List {
            Text("검색 결과가 없습니다.")
              .fontSystem(fontDesignSystem: .subtitle2_KO)
              .foregroundStyle(Color.white)
              .listRowSeparator(.hidden)
              .listRowBackground(Color.clear)
          }
          .foregroundStyle(Color.white)
          .listStyle(.plain)
        }
      }
    }
//    .fullScreenCover(isPresented: $showMusicTrimView) {
//      MusicTrimView(
//        musicVM: musicVM,
//        editorVM: editorVM,
//        videoPlayer: videoPlayer,
//        showMusicTrimView: $showMusicTrimView)
//    }
    .onAppear {
      // Music 목록을 가져오는 함수를 호출하고 musicList 배열을 업데이트합니다.
      Task {
        musicList = await apiViewModel.requestMusicList()
        downloadStatus = Dictionary(uniqueKeysWithValues: musicList.map { ($0, .beforeDownload) })
      }
    }
  }

  @ViewBuilder
  func glassMoriphicView(width: CGFloat, height: CGFloat, cornerRadius: CGFloat) -> some View {
    ZStack {
      RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        .fill(Color.black.opacity(0.3))
      CustomBlurView(effect: .systemUltraThinMaterialLight) { view in
        // FIXME: - 피그마와 비슷하도록 값 고치기
        view.saturationAmout = 2.2
        view.gaussianBlurRadius = 36
      }
      .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
    .frame(width: width, height: height)
  }

  @ViewBuilder
  func handleDownloadButton(for music: Music) -> some View {
    VStack {
      switch downloadStatus[music] ?? .beforeDownload {
      case .beforeDownload:
        Button {
          downloadAudioUsingAlamofire(for: music)
        } label: {
          playButton()
        }

      case .inProgress:
        Button {
          cancelDownload(for: music)
        } label: {
          downloadControlView(for: music)
        }

      case .complete:
        Button {
          playAudioFromTemporaryDirectory(for: music, fileURL: fileDirectories[music]!)
        } label: {
          playButton()
        }

      case .playing:
        Button {
          stopAudioFromTemporayDirectory(for: music)
        } label: {
          stopButton()
        }
      }
    }
  }

  @ViewBuilder
  func downloadControlView(for music: Music) -> some View {
    ZStack {
      stopButton()
      CircularProgressBar(progress: progressStatus[music] ?? 0.0)
    }
    .fixedSize()
  }

  @ViewBuilder
  func playButton() -> some View {
    Image(systemName: "play.fill")
      .font(.system(size: 20, weight: .regular))
      .padding(12)
  }

  @ViewBuilder
  func stopButton() -> some View {
    Image(systemName: "stop.fill")
      .font(.system(size: 20, weight: .regular))
      .padding(12)
  }
}

// MARK: - 음원 다운로드 관련 함수

extension MusicListView {
  /// url에서 음원 다운로드 함수
  /// - Parameters:
  ///   - music: 음원정보
  func downloadAudioUsingAlamofire(for music: Music) {
    let directoryURL = FileManager.default.temporaryDirectory
    let uniqueFileName = music.musicTitle + ".mp3"
    let fileURL = directoryURL.appendingPathComponent(uniqueFileName)
    fileDirectories[music] = fileURL
    let destination: DownloadRequest.Destination = { _, _ in
      if FileManager.default.fileExists(atPath: fileURL.path) {
        return (fileURL, [])
      } else {
        return (fileURL, [.createIntermediateDirectories])
      }
    }
    downloadStatus[music] = .inProgress

    if !FileManager.default.fileExists(atPath: fileURL.path) {
      let request = AF.download(music.musicURL, to: destination)
        .downloadProgress { progress in
          progressStatus[music] = progress.fractionCompleted
        }
        .response { response in
          switch response.result {
          case .success:
            print("successed!")
            downloadStatus[music] = .complete
          case .failure(let error):
            print("ERROR: \(error)")
            downloadStatus[music] = .beforeDownload
          }
        }
      downloadRequests[music] = request
    } else {
      downloadStatus[music] = .playing
      playAudioFromTemporaryDirectory(for: music, fileURL: fileDirectories[music]!)
    }
  }

  func cancelDownload(for music: Music) {
    guard musicList.firstIndex(where: { $0.id == music.id }) != nil else { return }
    downloadRequests[music]?.cancel()
    downloadStatus[music] = .beforeDownload
  }
}

// MARK: - 다운로드받은 음원 재생 관련 함수

extension MusicListView {
  /// 다운로드 받은 파일을 재생합니다.
  /// - Parameter fileURL: 임시 디렉토리의 url
  func playAudioFromTemporaryDirectory(for music: Music, fileURL: URL) {
    if FileManager.default.fileExists(atPath: fileURL.path) {
      DispatchQueue.main.async {
        do {
          let session = AVAudioSession.sharedInstance()
          try session.setCategory(.playback)
          try session.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
        } catch {
          print("Audio session setup failed: \(error.localizedDescription)")
        }

        do {
          // 이전에 생성한 AVAudioPlayer를 사용하고, 새로운 URL로 설정합니다.
          if let player = audioPlayer {
            currentMusic = music
            player.stop() // 이전 재생 중인 오디오를 중지합니다.
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
          } else {
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
          }

          // 오디오 재생
          if let player = audioPlayer {
            player.play()
            currentMusic = music
            downloadStatus[music] = .playing
            Timer.scheduledTimer(withTimeInterval: player.duration, repeats: false) { _ in
              player.pause()
              currentMusic = nil
              downloadStatus[music] = .complete
            }
          }
        } catch {
          print("AVAudioPlayer initialization failed: \(error.localizedDescription)")
        }
      }
    }
  }

  func stopAudioFromTemporayDirectory(for music: Music) {
    if let player = audioPlayer {
      player.stop() // 이전 재생 중인 오디오를 중지합니다.
      currentMusic = nil
      downloadStatus[music] = .complete
    }
  }

  func audioDuration(_ url: URL) -> TimeInterval {
    let asset = AVURLAsset(url: url)
    return asset.videoDuration()
  }
}

extension UIApplication {
  func endEditing() {
    sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  }
}

// MARK: - SearchBar

struct SearchBar: View {
  @Binding var searchText: String
  @Binding var isSearching: Bool

  var body: some View {
    ZStack {
      HStack(spacing: 0) {
        TextField("", text: $searchText, prompt: Text("Search").foregroundColor(Color.LabelColor_Secondary_Dark))
          .padding(.horizontal, 34)
          .frame(height: UIScreen.getHeight(36))
          .foregroundStyle(Color.LabelColor_Primary_Dark)
          .fontSystem(fontDesignSystem: .body1_KO)
          .background(Color.Dim_Default)
          .cornerRadius(10)
          .padding(.leading, 16)
          .padding(.trailing, isSearching ? 0 : 16)
          .onTapGesture {
            withAnimation {
              isSearching = true
            }
          }
          .onSubmit {
            withAnimation {
              isSearching = false
            }
          }
        if isSearching {
          Text("취소")
            .foregroundStyle(Color.Info)
            .fontSystem(fontDesignSystem: .body1_KO)
            .padding(.horizontal, 16)
            .contentShape(Rectangle())
            .onTapGesture {
              UIApplication.shared.endEditing()
              searchText = ""
              withAnimation {
                isSearching = false
              }
            }
        }
      }
      Image(systemName: "magnifyingglass")
        .foregroundStyle(Color.LabelColor_Secondary_Dark)
        .font(.system(size: 16))
        .hLeading()
        .padding(.leading, 24)

      if isSearching, !searchText.isEmpty {
        Button(action: {
          searchText = ""
        }) {
          Image(systemName: "xmark.circle.fill")
            .foregroundColor(Color.LabelColor_Secondary_Dark)
        }
        .hTrailing()
        .padding(.trailing, 66)
      }
    }
    .padding(.top, 16)
  }
}
