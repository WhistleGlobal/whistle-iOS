//
//  MusicListView.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import Alamofire
import AVFoundation
import AVKit
import Kingfisher
import SwiftUI

// MARK: - DownloadStatus

enum DownloadStatus {
  case beforeDownload
  case inProgress
  case suspend
  case resume
  case cancel
  case complete
  case playing
}

// MARK: - MusicListView

struct MusicListView: View {
  @State var searchQueryString = ""
  @State var musicList: [Music] = []
  @State var progressStatus: [Music: Double] = [:]
  @State var downloadStatus: [Music: DownloadStatus] = [:]
  @State var downloadRequests: [DownloadRequest?] = []
  @State var fileDirectories: [Music: URL] = [:]
  @State var audioPlayer: AVAudioPlayer?

  var filteredMusicList: [Music] {
    if searchQueryString.isEmpty {
      return musicList
    } else {
      return musicList.filter { $0.musicTitle.localizedStandardContains(searchQueryString) }
    }
  }

  @StateObject var apiViewModel = APIViewModel()
  var body: some View {
    SearchBar(text: $searchQueryString) {
      List(filteredMusicList, id: \.musicID) { music in
        HStack {
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
          Text("\(music.musicTitle)")
          Spacer()
          handleDownloadButton(for: music)
        }
      }
    }
    .listStyle(.inset)
    .navigationTitle("")
    .onAppear {
      let fileManager = FileManager.default
      let temporaryDirectory = FileManager.default.temporaryDirectory

      do {
        let files = try fileManager.contentsOfDirectory(atPath: temporaryDirectory.path)
        for file in files {
          let filePath = temporaryDirectory.appendingPathComponent(file)
          try fileManager.removeItem(at: filePath)
        }
      } catch { }
      // Music 목록을 가져오는 함수를 호출하고 musicList 배열을 업데이트합니다.
      Task {
        musicList = await apiViewModel.requestMusicList()
        downloadStatus = Dictionary(uniqueKeysWithValues: musicList.map { ($0, .beforeDownload) })
      }
    }
  }

  @ViewBuilder
  func handleDownloadButton(for music: Music) -> some View {
    VStack {
      switch downloadStatus[music] ?? .beforeDownload {
      case .beforeDownload:
        Button {
          downloadAudioUsingAlamofire(for: music)
        } label: {
          Image(systemName: "play.fill")
            .font(.system(size: 20, weight: .regular))
            .padding(12)
        }
      case .inProgress:
        Button {
//          suspendDownload(for: music)
          cancelDownload(for: music)
        } label: {
          downloadControlView(for: music)
        }

      case .suspend:
        Button {
          resumeDownload(for: music)
        } label: {
          Image(systemName: "pause.fill")
            .font(.system(size: 20, weight: .regular))
            .padding(12)
        }

      case .resume:
        downloadControlView(for: music)

      case .cancel:
        Button {
          cancelDownload(for: music)
        } label: {
          Image(systemName: "play.fill")
            .font(.system(size: 20, weight: .regular))
            .padding(12)
        }

      case .complete:
        Button {
          playAudioFromTemporaryDirectory(for: music, fileURL: fileDirectories[music]!)
        } label: {
          Image(systemName: "play.fill")
            .font(.system(size: 20, weight: .regular))
            .padding(12)
        }
      case .playing:
        Button {
          stopAudioFromTemporayDirectory(for: music)
        } label: {
          Image(systemName: "stop.fill")
            .font(.system(size: 20, weight: .regular))
            .padding(12)
        }
      }
    }
  }
  
  @ViewBuilder
  func downloadControlView(for music: Music) -> some View {
    ZStack {
      Image(systemName: "stop.fill")
        .font(.system(size: 20, weight: .regular))
        .padding(12)
      CircularProgressBar(progress: progressStatus[music] ?? 0.0)
    }
    .fixedSize()
  }


}

// MARK: - 음원 다운로드 관련 함수
extension MusicListView{

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

    if !FileManager.default.fileExists(atPath: fileURL.path) {
      let request = AF.download(music.musicURL, to: destination)
        .downloadProgress { progress in
          progressStatus[music] = progress.fractionCompleted
          downloadStatus[music] = .inProgress
        }
        .response { response in
          switch response.result {
          case .success(let fileURL):
            downloadStatus[music] = .complete
          case .failure(let error):
            downloadStatus[music] = .beforeDownload
          }
        }
      downloadRequests.append(request)
    }
  }

  func suspendDownload(for music: Music) {
    guard let index = musicList.firstIndex(where: { $0.id == music.id }) else { return }
    downloadStatus[music] = .suspend
    downloadRequests[index]?.suspend()
  }

  func resumeDownload(for music: Music) {
    guard let index = musicList.firstIndex(where: { $0.id == music.id }) else { return }
    downloadStatus[music] = .resume
    downloadRequests[index]?.resume()
  }

  func cancelDownload(for music: Music) {
    guard let index = musicList.firstIndex(where: { $0.id == music.id }) else { return }
    downloadStatus[music] = .beforeDownload
    downloadRequests[index]?.cancel()
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
            player.stop() // 이전 재생 중인 오디오를 중지합니다.
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
          } else {
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
          }

          // 오디오 재생
          if let player = audioPlayer {
            player.play()
            downloadStatus[music] = .playing
            Timer.scheduledTimer(withTimeInterval: player.duration, repeats: false) { _ in
              player.pause()
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
      downloadStatus[music] = .complete
    }
  }
}
//
// struct MusicListView_Previews: PreviewProvider {
//  static var previews: some View {
//    MusicListView(progressStatus: 1)
//  }
// }

