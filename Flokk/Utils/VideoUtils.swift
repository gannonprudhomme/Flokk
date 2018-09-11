//
//  VideoUtils.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 8/13/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import Foundation
import AVKit

// Collection of video support functions for Flokk
// getImageFromVideo based on https://stackoverflow.com/questions/32680526/display-a-preview-image-from-a-video-swift
class VideoUtils {
    static func resolutionForLocalVideo(url: URL) -> CGSize? {
        guard let track = AVURLAsset(url: url).tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: fabs(size.width), height: fabs(size.height))
    }
    
    // Generates an image from the first frame from the video at the specified filePath
    static func getImageFromVideo(filePath: String) -> UIImage? {
        let url = URL(fileURLWithPath: filePath)
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        
        let timestamp = CMTime(seconds: 0, preferredTimescale: 60)
        
        do {
            let imageRef = try generator.copyCGImage(at: timestamp, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch let error {
            print(error)
            return nil
        }
    }
}
