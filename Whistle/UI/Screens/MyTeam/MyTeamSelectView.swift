//
//  MyTeamSelectView.swift
//  Whistle
//
//  Created by ChoiYujin on 11/9/23.
//

import Foundation
import SwiftUI

// MARK: - MyTeamSelectView

struct MyTeamSelectView: View {

  @AppStorage("isMyTeamSelectPassed") var isMyTeamSelectPassed = false
  @Environment(\.dismiss) var dismiss
  @State private var currentIndex = 0
  @State private var isDragging = false
  @State var aniBool = false
  @StateObject var apiViewModel = APIViewModel.shared
  @StateObject private var tabbarModel = TabbarModel.shared
  var myTeamSelection: MyTeamType {
    MyTeamType.teamTypeList()[currentIndex]
  }

  var body: some View {
    VStack(spacing: 0) {
      Image("\(myTeamSelection.rawValue)Card")
        .resizable()
        .scaledToFit()
        .frame(width: UIScreen.getWidth(334), height: UIScreen.getHeight(444))
        .padding(.bottom, UIScreen.getHeight(24))
        .padding(.top, UIScreen.getHeight(14))
      Carousel(
        pageCount: 10,
        visibleEdgeSpace: 85,
        spacing: 37,
        currentIndex: $currentIndex,
        isDragging: $isDragging)
      { index in
        VStack(spacing: 10) {
          Image("\(MyTeamType.teamTypeList()[index].rawValue)Cell_disable")
            .resizable()
            .scaledToFit()
            .frame(width: UIScreen.getWidth(150), height: UIScreen.getHeight(100))
            .overlay {
              if currentIndex == index {
                Image("\(MyTeamType.teamTypeList()[index].rawValue)Cell")
                  .resizable()
                  .scaledToFit()
                  .frame(width: UIScreen.getWidth(150), height: UIScreen.getHeight(100))
                  .opacity(isDragging ? 0.0 : 1.0)
              }
            }
          Text(MyTeamType.teamName(MyTeamType.teamTypeList()[index]))
            .fontSystem(fontDesignSystem: .body2)
            .foregroundColor(.white)
        }
      }
      .frame(height: UIScreen.getHeight(150))
      .overlay {
        HStack(spacing: UIScreen.getWidth(164)) {
          Spacer()
          Button {
            currentIndex = max(currentIndex - 1, 0)
            isDragging = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
              isDragging = false
            }
          } label: {
            Image(systemName: "arrowtriangle.left.fill")
          }
          .disabled(currentIndex == 0)
          .opacity(currentIndex == 0 || isDragging ? 0.0 : 1.0)

          Button {
            currentIndex = min(currentIndex + 1, 9)
            isDragging = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
              isDragging = false
            }
          } label: {
            Image(systemName: "arrowtriangle.right.fill")
          }
          .disabled(currentIndex == 9)
          .opacity(currentIndex == 9 || isDragging ? 0.0 : 1.0)
          Spacer()
        }
        .font(.system(size: 19))
        .foregroundColor(.white)
        .padding(.bottom, UIScreen.getHeight(30))
      }
      .padding(.bottom, UIScreen.getHeight(14))
      Button {
        Task {
          await apiViewModel.updateMyTeam(myTeam: MyTeamType.teamName(myTeamSelection))
          await apiViewModel.requestMyProfile()
          if isMyTeamSelectPassed {
            dismiss()
          } else {
            isMyTeamSelectPassed = true
          }
        }
      } label: {
        Text(CommonWords().done)
          .font(.system(size: 16, weight: .semibold))
          .foregroundColor(.gray10)
          .frame(height: UIScreen.getHeight(56))
          .frame(maxWidth: .infinity)
          .background {
            glassProfile(cornerRadius: 14)
          }
      }
      .padding(.horizontal, 16)
      .padding(.bottom, UIScreen.getHeight(14))
      Text("마이팀은 선택 후 프로필 탭에서 언제든 변경할 수 있습니다.")
        .fontSystem(fontDesignSystem: .caption_Regular)
        .foregroundColor(.LabelColor_DisablePlaceholder)
      Spacer()
    }
    .toolbarRole(.editor)
    .navigationBarTitleDisplayMode(.inline)
    .background {
      MyTeamType.teamGradient(myTeamSelection).ignoresSafeArea(.all)
    }
    .toolbar {
      ToolbarItem(placement: .principal) {
        Text("마이팀을 선택해주세요")
          .font(.system(size: 17, weight: .semibold))
          .foregroundColor(.white)
      }
      ToolbarItem(placement: .confirmationAction) {
        Button("건너뛰기") {
          if isMyTeamSelectPassed {
            dismiss()
          } else {
            isMyTeamSelectPassed = true
          }
        }
        .fontSystem(fontDesignSystem: .body2)
        .foregroundColor(.LabelColor_DisablePlaceholder)
      }
    }
    .onAppear {
      tabbarModel.tabbarOpacity = 0.0
    }
    .onDisappear {
      tabbarModel.tabbarOpacity = 1.0
    }
  }
}

#Preview {
  MyTeamSelectView()
}

// MARK: - MyTeamType

enum MyTeamType: String {
  case samsung
  case doosan
  case kiwoom
  case ssg
  case hanwha
  case kt
  case lotte
  case nc
  case lg
  case kia

  static func teamTypeList() -> [MyTeamType] {
    [.samsung, .doosan, .kiwoom, .ssg, .hanwha, .kt, .lotte, .nc, .lg, .kia]
  }

  static func teamName(_ teamType: MyTeamType) -> String {
    switch teamType {
    case .samsung:
      return "삼성 라이온즈"
    case .doosan:
      return "두산 베어스"
    case .kiwoom:
      return "키움 히어로즈"
    case .ssg:
      return "SSG 랜더스"
    case .hanwha:
      return "한화 이글스"
    case .kt:
      return "KT 위즈"
    case .lotte:
      return "롯데 자이언츠"
    case .nc:
      return "NC 다이노스"
    case .lg:
      return "LG 트윈스"
    case .kia:
      return "KIA 타이거즈"
    }
  }

  static func teamGradient(_ teamType: MyTeamType) -> LinearGradient {
    switch teamType {
    case .samsung:
      return LinearGradient.samsungGradient
    case .doosan:
      return LinearGradient.doosanGradient
    case .kiwoom:
      return LinearGradient.kiwoomGradient
    case .ssg:
      return LinearGradient.ssgGradient
    case .hanwha:
      return LinearGradient.hanwhaGradient
    case .kt:
      return LinearGradient.ktGradient
    case .lotte:
      return LinearGradient.lotteGradient
    case .nc:
      return LinearGradient.ncGradient
    case .lg:
      return LinearGradient.lgGradient
    case .kia:
      return LinearGradient.kiaGradient
    }
  }

  static func teamGradient(_ teamName: String) -> LinearGradient {
    switch teamName {
    case "삼성 라이온즈":
      return LinearGradient.samsungGradient
    case "두산 베어스":
      return LinearGradient.doosanGradient
    case "키움 히어로즈":
      return LinearGradient.kiwoomGradient
    case "SSG 랜더스":
      return LinearGradient.ssgGradient
    case "한화 이글스":
      return LinearGradient.hanwhaGradient
    case "KT 위즈":
      return LinearGradient.ktGradient
    case "롯데 자이언츠":
      return LinearGradient.lotteGradient
    case "NC 다이노스":
      return LinearGradient.ncGradient
    case "LG 트윈스":
      return LinearGradient.lgGradient
    case "KIA 타이거즈":
      return LinearGradient.kiaGradient
    default:
      return LinearGradient(
        colors: [Color.clear],
        startPoint: .topLeading,
        endPoint: .bottomTrailing)
    }
  }

  static func teamProfile(_ teamName: String) -> Image {
    switch teamName {
    case "삼성 라이온즈":
      return Image("samsungProfile")
    case "두산 베어스":
      return Image("doosanProfile")
    case "키움 히어로즈":
      return Image("kiwoomProfile")
    case "SSG 랜더스":
      return Image("ssgProfile")
    case "한화 이글스":
      return Image("hanwhaProfile")
    case "KT 위즈":
      return Image("ktProfile")
    case "롯데 자이언츠":
      return Image("lotteProfile")
    case "NC 다이노스":
      return Image("ncProfile")
    case "LG 트윈스":
      return Image("lgProfile")
    case "KIA 타이거즈":
      return Image("kiaProfile")
    default:
      return Image("")
    }
  }

  static func teamLabel(_ teamName: String) -> Image {
    switch teamName {
    case "삼성 라이온즈":
      return Image("samsungLabel")
    case "두산 베어스":
      return Image("doosanLabel")
    case "키움 히어로즈":
      return Image("kiwoomLabel")
    case "SSG 랜더스":
      return Image("ssgLabel")
    case "한화 이글스":
      return Image("hanwhaLabel")
    case "KT 위즈":
      return Image("ktLabel")
    case "롯데 자이언츠":
      return Image("lotteLabel")
    case "NC 다이노스":
      return Image("ncLabel")
    case "LG 트윈스":
      return Image("lgLabel")
    case "KIA 타이거즈":
      return Image("kiaLabel")
    default:
      return Image("")
    }
  }
}
