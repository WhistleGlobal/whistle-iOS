//
//  MusicListView.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import SwiftUI

// MARK: - MusicListView

struct MusicListView: View {
  @State var searchQueryString = ""
  @State var musicList: [Music] = []
  var filteredMusicList: [Music] {
    if searchQueryString.isEmpty {
      return musicList
    } else {
      return musicList.filter { $0.musicTitle.localizedStandardContains(searchQueryString) }
    }
  }

  @StateObject var apiViewModel = APIViewModel()
  var body: some View {
    NavigationView {
      List(filteredMusicList, id: \.musicID) { music in
        NavigationLink(destination: Text(music.musicTitle)) {
          HStack {
            Text("\(music.musicTitle)")
            Spacer()
            Image(systemName: "play.fill")
              .padding(UIScreen.getWidth(12))
          }
        }
//        .foregroundColor(.White)
//        .onTapGesture { }
        .listRowSeparator(.hidden)
      }
      .padding(.horizontal, UIScreen.getWidth(16))
      .listStyle(.inset)
    }
    .searchable(text: $searchQueryString)
    .onAppear {
      // Music 목록을 가져오는 함수를 호출하고 musicList 배열을 업데이트합니다.
      Task {
        musicList = await apiViewModel.requestMusicList()
        print(musicList)
      }
    }
  }
}

// MARK: - MusicListView_Previews

struct MusicListView_Previews: PreviewProvider {
  static var previews: some View {
    MusicListView()
  }
}
