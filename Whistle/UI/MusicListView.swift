//
//  MusicListView.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import SwiftUI

// MARK: - MusicListView

struct MusicListView: View {
  @State var musicList: [Music] = []
  @StateObject var apiViewModel = APIViewModel()
  @State var searchText = ""
  var body: some View {
    NavigationStack {
      List(musicList, id: \.musicID) { music in
        HStack{
          NavigationLink(destination: Text(music.musicTitle)) {
            // 각 Music 항목을 텍스트로 표시합니다.
            Text("\(music.musicTitle) - \(music.musicArtist ?? "Unknown Artist")")
          }
          
        }
      }
      .navigationTitle("Music List")
    }
    .searchable(text: $searchText, prompt: Text("Search"))
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
