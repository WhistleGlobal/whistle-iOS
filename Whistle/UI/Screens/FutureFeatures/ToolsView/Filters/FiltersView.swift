//
//  FiltersView.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import SwiftUI

// MARK: - FiltersView

struct FiltersView: View {
  @State var selectedFilterName: String? = nil
  @ObservedObject var viewModel: VideoFiltersViewModel
  let onChangeFilter: (String?) -> Void
  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      LazyHStack(alignment: .center, spacing: 5) {
        resetButton
        ForEach(viewModel.images.sorted(by: { $0.filter.name < $1.filter.name })) { filterImage in
          imageView(filterImage.image, isSelected: selectedFilterName == filterImage.filter.name)
            .onTapGesture {
              selectedFilterName = filterImage.filter.name
            }
        }
      }
      .frame(height: 60)
      .padding(.horizontal)
    }
    .onChange(of: selectedFilterName) { newValue in
      onChangeFilter(newValue)
    }
    .padding(.horizontal, -16)
  }
}

// MARK: - FiltersView_Previews

struct FiltersView_Previews: PreviewProvider {
  @StateObject static var vm = VideoFiltersViewModel()
  static var previews: some View {
    FiltersView(selectedFilterName: nil, viewModel: vm, onChangeFilter: { _ in })
      .padding()
      .onAppear {
        vm.loadFilters(for: UIImage(named: "simpleImage")!)
      }
  }
}

extension FiltersView {
  private func imageView(_ uiImage: UIImage, isSelected: Bool) -> some View {
    Image(uiImage: uiImage)
      .resizable()
      .aspectRatio(contentMode: .fill)
      .frame(width: 55, height: 55)
      .clipped()
      .border(.white, width: isSelected ? 2 : 0)
  }

  private var resetButton: some View {
    Group {
      if let image = viewModel.image {
        imageView(image, isSelected: selectedFilterName == nil)
          .onTapGesture {
            selectedFilterName = nil
          }
          .padding(.trailing, 30)
      }
    }
  }
}
