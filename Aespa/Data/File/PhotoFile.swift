import Foundation
import SwiftUI
import UIKit

// MARK: - PhotoFile

/// `PhotoFile` struct models a photo file along with its related metadata.
///
/// The struct represents different details about a photo file, such as its creation date and the image itself.
/// To get more meta data from the image, you should refer to `PhotoAsset`
public struct PhotoFile {
  /// A `Date` value indicating the moment the photo was taken.
  public let creationDate: Date

  /// The captured image of type `UIImage`.
  public var image: UIImage

  public init(creationDate: Date, image: UIImage) {
    self.creationDate = creationDate
    self.image = image
  }
}

// MARK: Comparable

extension PhotoFile: Comparable {
  public static func < (lhs: PhotoFile, rhs: PhotoFile) -> Bool {
    lhs.creationDate > rhs.creationDate
  }
}

extension PhotoFile {
  /// The captured image presented as a SwiftUI `Image`.
  public var thumbnailImage: Image {
    Image(uiImage: image)
  }
}

// MARK: - AespaFileTypes

/// Namespace used by downstream modules to reference Aespa file models.
public enum AespaFileTypes {
  public typealias Photo = PhotoFile
  public typealias Video = VideoFile
}
