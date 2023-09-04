//
//  VideoModel.swift
//  Whistle
//
//  Created by 박상원 on 2023/08/23.
//

import Foundation
import AVFoundation

// MARK: - Video

struct Video : Identifiable {
    var id = UUID()
    var player : AVPlayer
    var likes: String
    var comments: String
    var url: String
}
