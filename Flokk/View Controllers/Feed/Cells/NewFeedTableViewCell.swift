//
//  NewFeedTableViewCell.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 8/15/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

// Based off of: http://fusionsoftwareconsulting.co.uk/2017/05/03/swift-3-embed-a-video-in-uitableviewcell/
class NewFeedTableViewCell: UITableViewCell {
    var avPlayer: AVPlayer?
    var avPlayerViewController: AVPlayerViewController?
    var avPlayerLayer: AVPlayerLayer?
    
    var videoItemURL: URL? {
        didSet {
            initNewPlayerItem()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpMoviePlayer()
    }

    private func setUpMoviePlayer() {
        // Create a new AVPlayer and AVPlayerLayer
        self.avPlayer = AVPlayer()
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
        
        // We want video controls so we need an AVPlayerViewController
        avPlayerViewController = AVPlayerViewController()
        avPlayerViewController?.player = avPlayer
        
        // Insert the player into the cell view hierarchy and setup autolayout
        avPlayerViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(avPlayerViewController!.view, at: 0)
        avPlayerViewController!.view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        avPlayerViewController!.view.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        avPlayerViewController!.view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        avPlayerViewController!.view.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }
    
    private func initNewPlayerItem() {
        // Pause the existing video
        avPlayer?.pause()
        
        // Check if URL is valid
        
        var videoAsset = AVAsset(url: videoItemURL!)
        videoAsset.loadValuesAsynchronously(forKeys: ["duration"], completionHandler:  { () in
            guard videoAsset.statusOfValue(forKey: "duration", error: nil) == .loaded else {
                return
            }
        })
        
        
        let videoPlayerItem = AVPlayerItem(asset: videoAsset)
        
        // Set this as the current avplayer item
        
    }
}
