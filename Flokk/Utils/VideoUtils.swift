//
//  VideoUtils.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 8/13/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import Foundation
import AVKit

class VideoUtils {
    static func resolutionForLocalVideo(url: URL) -> CGSize? {
        guard let track = AVURLAsset(url: url).tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: fabs(size.width), height: fabs(size.height))
    }
}
