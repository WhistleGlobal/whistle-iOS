//
//  UploadProtocol.swift
//  Whistle
//
//  Created by ChoiYujin on 9/8/23.
//

import Foundation
import UIKit

protocol UploadProtocol {
  func uploadPhoto(image: UIImage, completion: @escaping (String) -> Void) async
}
