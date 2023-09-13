//
//  TabbarView.swift
//  Whistle
//
//  Created by ChoiYujin on 8/30/23.
//

import SwiftUI

// MARK: - TabbarView

struct TabbarView: View {

  @State var tabSelection: TabSelection = .main
  @State var tabbarOpacity = 1.0
  @EnvironmentObject var apiViewModel: APIViewModel

  var body: some View {
    ZStack {
      switch tabSelection {
      case .main:
        // FIXME: - MainView로 교체하기 blur 확인용 테스트 이미지입니다.
        MainView()
          .environmentObject(apiViewModel)
      case .upload:
        // FIXME: - uploadview로 교체하기
        Color.pink.opacity(0.4).ignoresSafeArea()
      case .profile:
        ProfileView(tabbarOpacity: $tabbarOpacity, tabBarSelection: $tabSelection)
          .environmentObject(apiViewModel)
      }
      VStack {
        Spacer()
        glassMorphicTab()
          .overlay {
            Capsule()
              .stroke(lineWidth: 1)
              .foregroundStyle(
                LinearGradient.Border_Glass)
          }
          .overlay {
            tabItems()
          }
      }
      .padding(.horizontal, 16)
      .opacity(tabbarOpacity)
    }
  }
}

extension TabbarView {
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
            withAnimation {
              self.tabSelection = .main
            }
//            await apiViewModel.requestContentList()
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
          profileTabClicked()
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

// MARK: - TabClicked Actions
extension TabbarView {
  var profileTabClicked: () -> Void {
    {
      withAnimation(.default) {
        tabSelection = .profile
      }
      if apiViewModel.myProfile.userName.isEmpty {
        Task {
          await apiViewModel.requestMyProfile()
        }
        Task {
          await apiViewModel.requestMyFollow()
        }
        Task {
          await apiViewModel.requestMyWhistlesCount()
        }
        Task {
          await apiViewModel.requestMyBookmark()
        }
        Task {
          await apiViewModel.requestMyPostFeed()
        }
      }
    }
  }
}

// MARK: - TabSelection

public enum TabSelection: CGFloat {
  case main = -1.0
  case upload = 0.0
  case profile = 1.0
}
