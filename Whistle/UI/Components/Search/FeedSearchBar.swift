//
//  FeedSearchBar.swift
//  Whistle
//
//  Created by ChoiYujin on 11/13/23.
//

import Foundation
import SwiftUI

// MARK: - FeedSearchBar

struct FeedSearchBar: View {
  @State var colorModel: FeedSearchBarColorModel = .init()
  @State var isNeedBackButton = false
  @FocusState private var isFocused: Bool
  @Binding var searchText: String
  @Binding var isSearching: Bool
  var submitAction: () -> Void
  var cancelTapAction: DismissAction

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
            submitAction()
          }
          .overlay(alignment: .leading) {
            Image(systemName: "magnifyingglass")
              .foregroundStyle(colorModel.placeholderColor)
              .font(.system(size: 16))
              .padding(.leading, 8)
          }
          .overlay(alignment: .trailing) {
            if isSearching, !searchText.isEmpty {
              Button(action: {
                searchText = ""
              }) {
                Image(systemName: "xmark.circle.fill")
                  .font(.system(size: 16))
                  .foregroundColor(colorModel.placeholderColor)
              }
              .padding(.trailing, 4)
            }
          }
        if !isNeedBackButton {
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
              if isNeedBackButton {
                return
              }
              cancelTapAction()
            }
        }
      }
    }
    .tint(.Info)
    .onDisappear {
      UIApplication.shared.endEditing()
    }
  }
}

// MARK: - FeedSearchBarColorModel

class FeedSearchBarColorModel {
  var bgColor: Color = .init(hex: 0x767680, opacity: 0.24)
  var placeholderColor: Color = .Disable_Placeholder_Dark
  var cancelButtonColor: Color = .info
//  var textColor: Color = .labelColorPrimary
  var textColor: Color = .labelColorPrimary
}
