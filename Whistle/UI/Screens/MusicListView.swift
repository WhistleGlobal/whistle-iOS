//
//  MusicListView.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import Alamofire
import Kingfisher
import SwiftUI

// MARK: - DownloadProgress

enum DownloadProgress {
  case beforeDownload
  case inProgress
  case suspend
  case resume
  case cancel
  case complete
}

// MARK: - MusicListView

struct MusicListView: View {
  @State var searchQueryString = ""
  @State var musicList: [Music] = []
  @State var progressStatus = 0.0
  @State var downloadProgess: [(Int, DownloadProgress)] = [(0, .beforeDownload)]
  let musicURL = "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"
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
//              print("success \(response)")
            }
            .onFailure { _ in
//              print("failed \(response)")
            }
            .resizable()
            .frame(width: UIScreen.getWidth(64), height: UIScreen.getWidth(64))
            .cornerRadius(8)
          Text("\(music.musicTitle)")
          Spacer()
          switch downloadProgess[music.musicID].1 {
            case .beforeDownload:
              Image(systemName: "play.fill")
                .font(.system(size: 20, weight: .regular))
                .padding(12)
                .onTapGesture {
                  downloadProgess[music.musicID].1 = .inProgress
                  Task {
                    if let url = URL(string: music.musicURL) {
                      downloadAudioUsingAlamofire(from: url, withTitle: music.musicTitle, progress: $downloadProgess) { result in
                        switch result {
                          case let .success(fileURL):
                            print("다운로드 완료: \(fileURL)")
                          // 여기에서 파일을 사용하거나 저장할 수 있습니다.
                          case let .failure(error):
                            print("다운로드 실패: \(error)")
                        }
                      }
                    }
                  }
                }
            case .inProgress:
              ZStack {
                Image(systemName: "stop.fill")
                  .font(.system(size: 20, weight: .regular))
                  .padding(12)
                CircularProgressBar(progress: progressStatus)
              }
              .onTapGesture {
                downloadProgess[music.musicID].1 = .suspend
              }
              .fixedSize()
            case .suspend:
              Image(systemName: "pause.fill")
                .font(.system(size: 20, weight: .regular))
                .padding(12)
                .onTapGesture {
                  downloadProgess[music.musicID].1 = .resume
                }
            case .resume:
              Image(systemName: "stop.fill")
                .font(.system(size: 20, weight: .regular))
                .padding(12)
            case .cancel:
              Image(systemName: "play.fill")
                .font(.system(size: 20, weight: .regular))
                .padding(12)
            case .complete:
              Image(systemName: "play.fill")
                .font(.system(size: 20, weight: .regular))
                .padding(12)
          }
        }
      }
      .listStyle(.inset)
      .navigationTitle("")
      .onAppear {
        // Music 목록을 가져오는 함수를 호출하고 musicList 배열을 업데이트합니다.
        Task {
          musicList = await apiViewModel.requestMusicList()
          downloadProgess = downloadProgess + musicList.map { music in
            (music.musicID, .beforeDownload)
          }
        }
      }
    }
  }

  func downloadAudioUsingAlamofire(from url: URL, withTitle title: String, progress: Binding<[(Int, DownloadProgress)]>, completion: @escaping (Result<URL, Error>) -> Void) {
    let destination: DownloadRequest.Destination = { _, _ in
      let directoryURL = FileManager.default.temporaryDirectory
      let uniqueFileName = title + ".mp3"
      let fileURL = directoryURL.appendingPathComponent(uniqueFileName)
      if FileManager.default.fileExists(atPath: fileURL.path) {
        return (fileURL, [])
      } else {
        return (fileURL, [.createIntermediateDirectories])
      }
    }

    let request = AF.download(url, to: destination)
      .downloadProgress { progress in
        progressStatus = progress.fractionCompleted
      }
      .response { response in
        switch response.result {
          case let .success(fileURL):
            completion(.success(fileURL!))
          case let .failure(error):
            completion(.failure(error))
        }
      }
//    }
    request.suspend()
  }
}

// MARK: - CircularProgressBar

struct CircularProgressBar: View {
  var progress: Double

  @State private var animatedProgress = 0.0 // 애니메이션에 사용할 상태 변수

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        Circle()
          .stroke(lineWidth: 1.5)
          .foregroundColor(.Dim_Thin)
        Circle()
          .trim(from: 0.0, to: CGFloat(min(animatedProgress, 1.0))) // 애니메이션된 값 사용
          .stroke(style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
          .foregroundColor(.Gray10)
          .rotationEffect(Angle(degrees: 270.0))
      }
//      .padding(20.0)
      .frame(width: min(geometry.size.width, geometry.size.height), height: min(geometry.size.width, geometry.size.height))
      .onAppear {
        withAnimation(.linear(duration: 0.5)) { // 애니메이션 설정
          animatedProgress = progress
        }
      }
      .onChange(of: progress) { newValue in
        withAnimation(.linear(duration: 0.5)) { // 값이 변경될 때 애니메이션으로 업데이트
          animatedProgress = newValue
        }
      }
    }
  }
}

// MARK: - MusicListView_Previews

struct MusicListView_Previews: PreviewProvider {
  static var previews: some View {
    MusicListView(progressStatus: 1)
  }
}

// MARK: - SearchBarViewController

class SearchBarViewController<Content: View>: UIViewController {
  let searchController: UISearchController
  let contentViewController: UIHostingController<Content>

  init(searchController: UISearchController, withContent content: Content) {
    contentViewController = UIHostingController(rootView: content)
    self.searchController = searchController

    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func didMove(toParent parent: UIViewController?) {
    super.didMove(toParent: parent)

    guard
      let parent,
      parent.navigationItem.searchController == nil
    else {
      return
    }
    parent.navigationItem.searchController = searchController
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(contentViewController.view)
    contentViewController.view.frame = view.bounds
  }
}

// MARK: - SearchBar

struct SearchBar<Content: View>: UIViewControllerRepresentable {
  typealias UIViewControllerType = SearchBarViewController<Content>

  @Binding var text: String
  @ViewBuilder var content: () -> Content

  class Coordinator: NSObject, UISearchResultsUpdating {
    @Binding var text: String

    init(text: Binding<String>) {
      _text = text
    }

    func updateSearchResults(for searchController: UISearchController) {
      if text != searchController.searchBar.text {
        text = searchController.searchBar.text ?? ""
      }
    }
  }

  func makeCoordinator() -> SearchBar.Coordinator {
    Coordinator(text: $text)
  }

  func makeUIViewController(context: UIViewControllerRepresentableContext<SearchBar>) -> UIViewControllerType {
    let searchController = UISearchController(searchResultsController: nil)
    searchController.searchResultsUpdater = context.coordinator

    return SearchBarViewController(searchController: searchController, withContent: content())
  }

  func updateUIViewController(
    _ uiViewController: UIViewControllerType,
    context _: UIViewControllerRepresentableContext<SearchBar>
  ) {
    let contentViewController = uiViewController.contentViewController

    contentViewController.view.removeFromSuperview()
    contentViewController.rootView = content()
    uiViewController.view.addSubview(contentViewController.view)
    contentViewController.view.frame = uiViewController.view.bounds
  }
}
