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
    
    var avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer! = nil // Initialized when the video is added to the view
    
    // Created when the preview image is added
    var previewImageView: UIImageView!
    
    // If the video is paused or not
    var isPaused = true // Videos start out paused?
    
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
        
        // Remove the video layer to prevent it stacking with the next video that will occupy this cell
        if avPlayerLayer != nil {
            avPlayerLayer.removeFromSuperlayer()
            avPlayer.pause()
        }
        
        // Same as above
        if previewImageView != nil {
            previewImageView.removeFromSuperview()
        }
    }
    
    func initialize() {
        // Add listener for the end of the video, causing it to loop
        NotificationCenter.default.addObserver(self, selector: #selector(self.restartVideo), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem)
        
        setAspectRatio()
        addPlayTouchGesture()
        
        //addPreviewImageToView(image: UIImage(named: "testPhoto2")!)

        // Add preview image while the video is loading
        beginLoadingVideo(completion: { (loaded) in
            self.addVideoToView()
        })
    }
    
    // Adds the gesture for pausing & playing the video by tapping it
    func addPlayTouchGesture() {
        let touchGesture = UITapGestureRecognizer(target: self, action: #selector(self.mainViewPressed(_:)))
        mainView.addGestureRecognizer(touchGesture)
    }
    
    @objc func mainViewPressed(_ sender: UITapGestureRecognizer) {
        // If avPlayerLayer is initialized, then the video has been loaded
        if isPaused { // If the video is paused, play it
            playVideo()
        } else {
            pauseVideo()
        }
    }
}

// MARK: - Loading functions
extension FeedTableViewCell {
    func setAspectRatio() {
        // Calculate the aspect ratio of the video/post
        let aspect = Float((self.post.dimensions?.width)!) / Float((self.post.dimensions?.height)!)
        
        // Create the aspect ratio constraint, which resizes this cell's height
        let constraint = NSLayoutConstraint(item: mainView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: mainView, attribute: NSLayoutAttribute.height, multiplier: CGFloat(aspect), constant: 0.0)
        
        constraint.priority = UILayoutPriority(rawValue: 999)
        
        aspectConstraint = constraint
    }
    
    // Set the preview image on the view
    func addPreviewImageToView(image: UIImage) {
        previewImageView = UIImageView(image: image)
        
        mainView.addSubview(previewImageView)
        previewImageView.frame = mainView.bounds
        
        // Add a loading icon?
    }
    
    func beginLoadingVideo(completion: @escaping (Bool) -> Void) {
        // First check if the video has already been loaded
        
        // Firebase stuff
        completion(true)
    }
    
    // Once the video has been loaded, this will be called
    func addVideoToView() {
        // If there was a preview image, remove it from the mainView
        //previewImageView.isHidden = true
        
        // Calculate the aspect constraint
        setAspectRatio()
        
        let aspect = Float((self.post.dimensions?.width)!) / Float((self.post.dimensions?.height)!)
        
        // Recalculate the height for the view itself
        // The AVPlayer's bounds are detetmined by the mainView, without this the cell would be the right size
        // but the video would be cut too short
        mainView.bounds.size = CGSize(width: mainView.bounds.width, height: mainView.bounds.width / CGFloat(aspect))
        
        // Initialize & setup AVPlayer
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = self.mainView.bounds
        avPlayerLayer.videoGravity = .resizeAspectFill
        self.mainView.layer.insertSublayer(avPlayerLayer, at: 0)
        
        let playerItem = AVPlayerItem(url: self.post.fileURL!)
        avPlayer.replaceCurrentItem(with: playerItem)
        //avPlayer.play()
    }
}

// MARK: - Video Functions
extension FeedTableViewCell {
    func playVideo() {
        if avPlayerLayer != nil {
            isPaused = false
            avPlayer.play()
        }
    }
    
    func pauseVideo() {
        if avPlayerLayer != nil {
            isPaused = true
            avPlayer.pause()
        }
    }
    
    @objc func restartVideo() {
        avPlayer.seek(to: CMTime(seconds: 0, preferredTimescale: 1000));
        playVideo()
    }
    
    func resolutionForLocalVideo(url: URL) -> CGSize? {
        guard let track = AVURLAsset(url: url).tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: fabs(size.width), height: fabs(size.height))
    }
}
