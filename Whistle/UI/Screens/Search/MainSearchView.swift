//
//  MainSearchView.swift
//  Whistle
//
//  Created by ChoiYujin on 11/9/23.
//

import SwiftUI
import UIKit

// MARK: - MainSearchView

struct MainSearchView: View {

  @State var searchText = ""
  @State var searchHistory: [String] = []
  @State var text = ""
  @State var scopeSelection = 0
  @State var searchQueryString = ""
  @State var isSearching = false

  var body: some View {
    VStack(spacing: 0) {
      Spacer().frame(height: 106)
      Divider()
      HStack {
        Text("최근 검색")
          .fontSystem(fontDesignSystem: .subtitle1)
          .foregroundColor(.LabelColor_Primary)
        Spacer()
        Button {
          //
        } label: {
          Text("모두 지우기")
            .fontSystem(fontDesignSystem: .subtitle3)
            .foregroundColor(.info)
        }
      }
      .padding(.horizontal, 16)
      .frame(height: 50)
      // 검색 목록 넣을 것
      NavigationLink {
        SearchResultView()
      } label: {
        HStack(spacing: 0) {
          Image(systemName: "magnifyingglass")
            .font(.system(size: 28))
            .frame(width: 48, height: 48)
            .padding(.trailing, 10)
          Text("뽀삐뽀삐뽀뽀삐뽀")
            .fontSystem(fontDesignSystem: .body2)
            .foregroundColor(.LabelColor_Primary)
          Spacer()
          Image(systemName: "xmark")
            .font(.system(size: 16))
            .frame(width: 16, height: 16)
            .foregroundColor(.LabelColor_Primary)
            .onTapGesture {
              WhistleLogger.logger.debug("x remove")
            }
        }
        .frame(height: 74)
      }
      .padding(.horizontal, 16)
      Spacer()
    }
    .background()
  }
}

#Preview {
  MainSearchView()
}

// MARK: - FeedSearchBar

struct FeedSearchBar: View {
  @State var colorModel: FeedSearchBarColorModel = .init()
  @State var isNeedBackButton = false
  @FocusState private var isFocused: Bool
  @Binding var searchText: String
  @Binding var isSearching: Bool

  var body: some View {
    ZStack {
      HStack(spacing: 0) {
        TextField("", text: $searchText, prompt: Text("Search").foregroundColor(Color.Disable_Placeholder_Dark))
          .focused($isFocused)
          .padding(.horizontal, 34)
          .frame(height: UIScreen.getHeight(28))
          .foregroundStyle(colorModel.textColor)
          .fontSystem(fontDesignSystem: .body1)
          .background(colorModel.bgColor)
          .cornerRadius(10)
          .onTapGesture {
            isFocused = true
            withAnimation {
              isSearching = true
            }
          }
          .onSubmit {
            withAnimation {
              isSearching = false
              isFocused = false
            }
          }
          .overlay(alignment: .leading) {
            Image(systemName: "magnifyingglass")
              .foregroundStyle(colorModel.placeholderColor)
              .font(.system(size: 16))
              .hLeading()
              .padding(.leading, 8)
          }
          .overlay(alignment: .trailing) {
            if isSearching, !searchText.isEmpty {
              Button(action: {
                searchText = ""
              }) {
                Image(systemName: "xmark.circle.fill")
                  .foregroundColor(colorModel.placeholderColor)
              }
              .hTrailing()
              .padding(.trailing, 8)
            }
          }
        if isSearching {
          Text(CommonWords().cancel)
            .foregroundStyle(colorModel.cancelButtonColor)
            .fontSystem(fontDesignSystem: .body1)
            .padding(.leading, 16)
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
    }
    .frame(width: searchBarWidth())
//    .padding(.horizontal, 16)
//    .padding(.top, 16)
//    .padding(.bottom, 8)
    .onDisappear {
      UIApplication.shared.endEditing()
    }
  }

  func searchBarWidth() -> CGFloat {
    withAnimation {
      if isNeedBackButton {
        if isSearching {
          return UIScreen.width - 32
        } else {
          return UIScreen.width - 32 - 24
        }
      } else {
        return UIScreen.width - 32
      }
    }
  }
}

// MARK: - FeedSearchBarColorModel

class FeedSearchBarColorModel {
  var bgColor: Color = .init(hex: 0x767680, opacity: 0.24)
  var placeholderColor: Color = .Disable_Placeholder_Dark
  var cancelButtonColor: Color = .info
  var textColor: Color = .LabelColor_Primary
}
