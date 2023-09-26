//
//  RootView.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import PhotosUI
import SwiftUI

// MARK: - RootView

struct RootView: View {
  @ObservedObject var rootVM: RootViewModel
  @State private var item: PhotosPickerItem?
  @State private var selectedVideoURL: URL?
  @State private var showLoader = false
  @State private var showEditor = false
  let columns = [
    GridItem(.adaptive(minimum: 150)),
    GridItem(.adaptive(minimum: 150)),
  ]
  var body: some View {
    NavigationStack {
      ZStack {
        ScrollView(.vertical, showsIndicators: false) {
          VStack(alignment: .leading) {
            Text("My projects")
              .font(.headline)
            newProjectButton
          }
          .padding()
        }
      }
      .navigationDestination(isPresented: $showEditor) {
        MainEditorView(selectedVideoURl: selectedVideoURL)
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Text("Video editor")
            .font(.title2.bold())
        }
      }
      .onChange(of: item) { newItem in
        loadPhotosItem(newItem)
      }
      .onAppear {
        rootVM.fetch()
      }
      .overlay {
        if showLoader {
          Color.secondary.opacity(0.2).ignoresSafeArea()
          VStack(spacing: 10) {
            Text("Loading video")
            ProgressView()
          }
          .padding()
          .frame(height: 100)
          .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
        }
      }
    }
  }
}

// MARK: - RootView_Previews2

// struct RootView_Previews2: PreviewProvider {
//  static var previews: some View {
//    RootView(rootVM: RootViewModel(mainContext: dev.viewContext))
//  }
// }

extension RootView {
  private var newProjectButton: some View {
    PhotosPicker(selection: $item, matching: .videos) {
      VStack(spacing: 10) {
        Image(systemName: "plus")
        Text("New project")
      }
      .hCenter()
      .frame(height: 150)
      .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 5))
      .foregroundColor(.white)
    }
  }

  private func loadPhotosItem(_ newItem: PhotosPickerItem?) {
    Task {
      self.showLoader = true
      if let video = try await newItem?.loadTransferable(type: VideoItem.self) {
        selectedVideoURL = video.url
        try await Task.sleep(for: .milliseconds(50))
        self.showLoader = false
        self.showEditor.toggle()

      } else {
        print("Failed load video")
        self.showLoader = false
      }
    }
  }
}
