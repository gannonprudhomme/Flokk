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
    var avPlayerLayer: AVPlayerLayer?
    var videoItemURL: URL?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        
    }
}
