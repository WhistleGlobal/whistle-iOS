//
//  BottomSheetTestView.swift
//  Whistle
//
//  Created by ChoiYujin on 10/7/23.
//

import BottomSheet
import ReverseMask
import SwiftUI


// MARK: - BottomSheetTestView

struct BottomSheetTestView: View {

  @State var bottomSheetPosition: BottomSheetPosition = .absolute(406)
  @State var selectedSec: SelectedSecond = .sec3
  @State var dragOffset: CGFloat = 0
  var barSpacing: CGFloat {
    CGFloat((UIScreen.width - 32 - 12 - (14 * 6)) / 15)
  }

  var defaultWidth: CGFloat {
    CGFloat(6 + (6 + barSpacing) * 8)
  }

  var body: some View {
    VStack {
      Color.clear
    }
    .onChange(of: dragOffset, perform: { _ in
      log(dragOffset)
    })
    .bottomSheet(
      bottomSheetPosition: $bottomSheetPosition,
      switchablePositions: [.hidden, .absolute(406)])
    {
      VStack(spacing: 0) {
        HStack {
          Color.clear.frame(width: 28)
          Spacer()
          Text("타이머")
            .fontSystem(fontDesignSystem: .subtitle1_KO)
            .foregroundColor(.White)
          Spacer()
          Text("취소")
            .fontSystem(fontDesignSystem: .subtitle2_KO)
            .foregroundColor(.White)
        }
        .frame(height: 24)
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        Divider().frame(width: UIScreen.width)
        HStack {
          Text("카운트 다운")
            .fontSystem(fontDesignSystem: .subtitle1_KO)
            .foregroundColor(.LabelColor_Primary_Dark)
          Spacer()
          ZStack {
            glassToggle(width: 120, height: 34)
              .overlay {
                Capsule()
                  .stroke(lineWidth: 1)
                  .foregroundStyle(LinearGradient.Border_Glass)
                  .frame(width: 120, height: 34)
                  .overlay {
                    HStack(spacing: 0) {
                      if selectedSec == .sec10 {
                        Spacer()
                      }
                      Capsule()
                        .frame(width: 58, height: 30)
                        .foregroundColor(Color.Dim_Default)
                        .overlay {
                          Capsule()
                            .stroke(lineWidth: 1)
                            .foregroundStyle(LinearGradient.Border_Glass)
                        }
                      if selectedSec == .sec3 {
                        Spacer()
                      }
                    }
                    .frame(width: 116, height: 34)
                    .padding(.horizontal, 2)
                  }
              }
            HStack(spacing: 0) {
              Spacer()
              Text("3s")
                .fontSystem(fontDesignSystem: .subtitle3_KO)
                .foregroundColor(selectedSec == .sec3 ? .White : Color.LabelColor_DisablePlaceholder)
                .onTapGesture {
                  withAnimation {
                    let dragValue = Int(dragOffset + defaultWidth)
                    let multiplier = 6 + barSpacing
                    selectedSec = .sec3
                    dragOffset = -5.0 * CGFloat(multiplier)
                  }
                }
                .frame(width: 58, height: 30)
              Text("10s")
                .fontSystem(fontDesignSystem: .subtitle3_KO)
                .foregroundColor(selectedSec == .sec10 ? .White : Color.LabelColor_DisablePlaceholder)
                .onTapGesture {
                  withAnimation {
                    let dragValue = Int(dragOffset + defaultWidth)
                    let multiplier = 6 + barSpacing
                    dragOffset = 2.0 * CGFloat(multiplier)
                    selectedSec = .sec10
                  }
                }
                .frame(width: 58, height: 30)
              Spacer()
            }
            .frame(width: 120, height: 34)
          }
          .frame(width: 120, height: 34)
        }
        .frame(width: UIScreen.width - 32, alignment: .leading)
        .padding(.horizontal, 16)
        .frame(height: 64)
        // MARK: - 드래그
        HStack(alignment: .bottom) {
          RoundedRectangle(cornerRadius: 8)
            .foregroundColor(Color.Gray30_Dark)
            .frame(width: UIScreen.width - 32)
            .frame(height: 84)
            .reverseMask {
              RoundedRectangle(cornerRadius: 8)
                .frame(width: UIScreen.width - 48)
                .frame(height: 72)
            }
            .overlay {
              HStack(spacing: 0) {
                Spacer().frame(minWidth: 0)
                ForEach(0..<14) { i in
                  Capsule()
                    .frame(width: 6, height: i % 2 == 0 ? 22 : 42)
                    .foregroundColor(Color.Gray30_Dark)
                  Spacer().frame(minWidth: 0)
                }
              }
              .padding(.horizontal, 6)
            }
            .overlay {
              HStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 8)
                  .foregroundStyle(
                    LinearGradient(colors: [
                      Color.Primary_Darken,
                      Color.Secondary_Darken,
                    ], startPoint: .leading, endPoint: .trailing))
                  .frame(width: CGFloat(defaultWidth + dragOffset), height: 84, alignment: .leading)
                  .overlay {
                    HStack(spacing: 0) {
                      Spacer().frame(width: 8)
                      Spacer()
                      Spacer().frame(width: 34)
                        .overlay {
                          Capsule()
                            .foregroundColor(.white)
                            .frame(width: 4, height: 22)
                        }
                    }
                  }
                  .reverseMask {
                    HStack(spacing: 0) {
                      Spacer().frame(width: 8)
                      RoundedRectangle(cornerRadius: 8)
                        .frame(height: 72)
                        .frame(maxWidth: .infinity)
                      Spacer().frame(width: 34)
                    }
                  }
                  .gesture(
                    DragGesture()
                      .onChanged { value in
                        if
                          CGFloat(defaultWidth + value.translation.width) >
                          CGFloat(UIScreen.width - 32)
                        {
                          dragOffset = CGFloat((6 + barSpacing) * 7)
                        } else if defaultWidth + value.translation.width < 6 {
                          dragOffset = -CGFloat((6 + barSpacing) * 8)
                        } else {
                          dragOffset = value.translation.width
                        }
                      }
                      .onEnded { _ in
                        let dragValue = Int(dragOffset + defaultWidth)
                        let multiplier = 6 + barSpacing
                        switch dragValue {
                        case .min..<6:
                          withAnimation {
                            dragOffset = -8.0 * CGFloat(multiplier)
                          }
                        case 6 - Int(barSpacing)..<Int(multiplier) + Int(barSpacing):
                          withAnimation {
                            dragOffset = -7.0 * CGFloat(multiplier)
                          }
                        case Int(multiplier) - Int(barSpacing)..<Int(2 * multiplier) + Int(barSpacing):
                          withAnimation {
                            dragOffset = -6.0 * CGFloat(multiplier)
                          }
                        case Int(2 * multiplier) - Int(barSpacing)..<Int(3 * multiplier) +
                          Int(barSpacing):
                          withAnimation {
                            dragOffset = -5.0 * CGFloat(multiplier)
                          }
                        case Int(3 * multiplier) - Int(barSpacing)..<Int(4 * multiplier) +
                          Int(barSpacing):
                          withAnimation {
                            dragOffset = -4.0 * CGFloat(multiplier)
                          }
                        case Int(4 * multiplier) - Int(barSpacing)..<Int(5 * multiplier) +
                          Int(barSpacing):
                          withAnimation {
                            dragOffset = -3.0 * CGFloat(multiplier)
                          }
                        case Int(5 * multiplier) - Int(barSpacing)..<Int(6 * multiplier) +
                          Int(barSpacing):
                          withAnimation {
                            dragOffset = -2.0 * CGFloat(multiplier)
                          }
                        case Int(6 * multiplier) - Int(barSpacing)..<Int(7 * multiplier) +
                          Int(barSpacing):
                          withAnimation {
                            dragOffset = -CGFloat(multiplier)
                          }
                        case Int(7 * multiplier) - Int(barSpacing)..<Int(8 * multiplier) +
                          Int(barSpacing):
                          withAnimation {
                            dragOffset = 0.0
                          }
                        case Int(8 * multiplier) - Int(barSpacing)..<Int(9 * multiplier) +
                          Int(barSpacing):
                          withAnimation {
                            dragOffset = CGFloat(multiplier)
                          }
                        case Int(9 * multiplier) - Int(barSpacing)..<Int(10 * multiplier) +
                          Int(barSpacing):
                          withAnimation {
                            dragOffset = 2.0 * CGFloat(multiplier)
                          }
                        case Int(10 * multiplier) - Int(barSpacing)..<Int(11 * multiplier) +
                          Int(barSpacing):
                          withAnimation {
                            dragOffset = 3.0 * CGFloat(multiplier)
                          }
                        case Int(11 * multiplier) - Int(barSpacing)..<Int(12 * multiplier) +
                          Int(barSpacing):
                          withAnimation {
                            dragOffset = 4.0 * CGFloat(multiplier)
                          }
                        case Int(12 * multiplier) - Int(barSpacing)..<Int(13 * multiplier) +
                          Int(barSpacing):
                          withAnimation {
                            dragOffset = 5.0 * CGFloat(multiplier)
                          }
                        case 15 - Int(barSpacing)...Int.max:
                          withAnimation {
                            dragOffset = 6.0 * CGFloat(multiplier)
                          }
                        default:
                          log("")
                        }
                      })
              }
              HStack {
                Text("0s")
                Spacer()
                Text("15s")
              }
              .foregroundColor(Color.Gray30_Dark)
              .fontSystem(fontDesignSystem: .caption_KO_Semibold)
              .offset(y: -53)
              HStack {
                Text("\(Int((defaultWidth + dragOffset - 6) / (barSpacing + 6)))s")
                  .foregroundColor(Color.White)
                  .fontSystem(fontDesignSystem: .caption_KO_Semibold)
                  .frame(maxWidth: .infinity, alignment: .trailing)
              }
              .foregroundColor(Color.LabelColor_Primary_Dark)
              .fontSystem(fontDesignSystem: .caption_KO_Semibold)
              .frame(width: dragOffset + defaultWidth)
              .offset(y: -53)
            }
            .frame(height: 104)
        }
        .frame(width: UIScreen.width - 32, alignment: .leading)
        HStack {
          Text("끌어서 이 영상의 길이를 선택하세요. 타이머를 설정하면 녹화가 시작되기 전에 카운트 다운이 실행됩니다.")
            .fontSystem(fontDesignSystem: .caption_KO_Regular)
            .foregroundColor(Color.LabelColor_Primary_Dark)
        }
        .padding([.horizontal, .bottom], 16)
        .frame(height: 60)
        Button { } label: {
          Text("타이머 설정")
            .fontSystem(fontDesignSystem: .subtitle2_KO)
            .foregroundColor(Color.LabelColor_Primary_Dark)
            .frame(maxWidth: .infinity)
            .background {
              Capsule()
                .frame(height: 48)
                .frame(maxWidth: .infinity)
                .foregroundColor(Color.Blue_Default)
            }
        }
        .padding(.horizontal, 16)
        Spacer()
      }
    }
    .enableSwipeToDismiss(true)
    .enableTapToDismiss(true)
    .enableContentDrag(true)
    .enableAppleScrollBehavior(false)
    .dragIndicatorColor(Color.Border_Default_Dark)
    .customBackground(
      glassMorphicView(width: UIScreen.width, height: .infinity, cornerRadius: 24)
        .overlay {
          RoundedRectangle(cornerRadius: 24)
            .stroke(lineWidth: 1)
            .foregroundStyle(
              LinearGradient.Border_Glass)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        })
  }
}

// MARK: - SelectedSecond

enum SelectedSecond: Int {
  case sec3 = -1
  case sec10 = 1
}

extension BottomSheetTestView {
  @ViewBuilder
  func glassToggle(width: CGFloat, height: CGFloat) -> some View {
    ZStack {
      Capsule()
        .fill(Color.black.opacity(0.3))
      CustomBlurView(effect: .systemUltraThinMaterialLight) { view in
        view.saturationAmout = 2.2
        view.gaussianBlurRadius = 32
      }
      .clipShape(Capsule())
    }
    .frame(width: width, height: height)
  }
}
