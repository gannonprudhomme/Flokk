//
//  FeedTableViewCell.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 7/28/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import UIKit
import AVFoundation

class FeedTableViewCell: UITableViewCell {
    @IBOutlet weak var mainView: UIView!
    var post: Post! // THe post this cell is representing
    
    let avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer! = nil
    
    internal var aspectConstraint: NSLayoutConstraint? {
        didSet {
            if oldValue != nil {
                mainView.removeConstraint(oldValue!)
            }
            
            if aspectConstraint != nil {
                mainView.addConstraint(aspectConstraint!)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        aspectConstraint = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // What would need to be done here?
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

// MARK: - Loading functions
extension FeedTableViewCell {
    func setAspectRatio() {
        // Calculate the aspect ratio of the video/post
        let width: Int = (self.post.dimensions?.width)!
        let height: Int = (self.post.dimensions?.height)!
        let aspect: Float = Float(width) / Float(height)
        
        // Create the aspect ratio constraint, which resizes this cell's height
        let constraint = NSLayoutConstraint(item: mainView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: mainView, attribute: NSLayoutAttribute.height, multiplier: CGFloat(aspect), constant: 0.0)
        
        constraint.priority = UILayoutPriority(rawValue: 999)
        
        aspectConstraint = constraint
        
        // Recalculate the height for the view itself
        // The AVPlayer's bounds are detetmined by the mainView, without this the cell would be the right size
        // but the video would be cut too short
        mainView.bounds.size = CGSize(width: mainView.bounds.width, height: mainView.bounds.width / CGFloat(aspect))
    }
    
    // Set the preview image on the view
    func addPreviewImageToView(image: UIImage) {
        // Create a UIImage
        
        // Add the image to the view
        
        // Add a loading icon?
    }
    
    func addVideoToView() {
        // If there was a preview image, remove it from the mainView
        
        // Calculate the aspect constraint
        setAspectRatio()
        
        // Initialize & setup AVPlayer
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = self.mainView.bounds
        avPlayerLayer.videoGravity = .resizeAspectFill
        self.mainView.layer.insertSublayer(avPlayerLayer, at: 0)
        
        let playerItem = AVPlayerItem(url: self.post.fileURL!)
        avPlayer.replaceCurrentItem(with: playerItem)
        avPlayer.play()
    }
    
    func resolutionForLocalVideo(url: URL) -> CGSize? {
        guard let track = AVURLAsset(url: url).tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: fabs(size.width), height: fabs(size.height))
    }
}
