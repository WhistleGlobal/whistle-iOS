//
//  VideoFiltersViewModel.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/11.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

class VideoFiltersViewModel: ObservableObject {
  @Published var images = [FilteredImage]()
  @Published var colorCorrection = ColorCorrection()
  @Published var value = 1.0

  var image: UIImage?

  private let filters: [CIFilter] = [
    .photoEffectChrome(),
    .photoEffectFade(),
    .photoEffectInstant(),
    .photoEffectMono(),
    .photoEffectNoir(),
    .photoEffectProcess(),
    .photoEffectTonal(),
    .photoEffectTransfer(),
    .sepiaTone(),
    .thermal(),
    .vignette(),
    .vignetteEffect(),
    .xRay(),
    .gaussianBlur(),
  ]

  func loadFilters(for image: UIImage) {
    self.image = image
    let context = CIContext()
    filters.forEach { filter in
      DispatchQueue.global(qos: .userInteractive).async {
        guard let ciImage = CIImage(image: image) else { return }
        filter.setValue(ciImage, forKey: kCIInputImageKey)

        guard
          let newImage = filter.outputImage,
          let cgImage = context.createCGImage(newImage, from: ciImage.extent)
        else { return }

        let filterImage = FilteredImage(image: UIImage(cgImage: cgImage), filter: filter)

        DispatchQueue.main.async {
          self.images.append(filterImage)
        }
      }
    }
  }
}
