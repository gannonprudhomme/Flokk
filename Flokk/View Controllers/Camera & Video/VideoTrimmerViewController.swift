//
//  VideoTrimmerViewController.swift
//  Flokk
//
//  Created by Gannon Prudomme on 7/10/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import UIKit
import AVFoundation
import ABVideoRangeSlider

class VideoTrimmerViewController: UIViewController {
    @IBOutlet weak var videoCanvasView: UIView!
    @IBOutlet var rangeSlider: ABVideoRangeSlider!
    
    var videoURL: URL!
    
    var avPlayer: AVPlayer!
    var avPlayerLayer: AVPlayerLayer!
    
    var startTime: CMTime!
    var endTime: CMTime!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //videoURL = URL(string: "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8")
        
        avPlayer = AVPlayer()
        
        // Add the callback function to the AVPlayer to make it loop
        NotificationCenter.default.addObserver(self, selector: #selector(VideoTrimmerViewController.videoEnded), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem)
        
        // Set up the AVPlayer to play the video
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = videoCanvasView.bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoCanvasView.layer.insertSublayer(avPlayerLayer, at: 0)
        
        self.view.layoutIfNeeded()
        
        let playerItem = AVPlayerItem(url: videoURL as URL)
        avPlayer.replaceCurrentItem(with: playerItem)
        
        // Start playing the video
        avPlayer.play()
        
        // Video Range Slider set up
        rangeSlider.setVideoURL(videoURL: videoURL)
        rangeSlider.delegate = self
        rangeSlider.minSpace = 6
        rangeSlider.maxSpace = 6
        
        self.rangeSlider.updateThumbnails()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func videoEnded() {
        avPlayer.seek(to: CMTime(seconds: 0, preferredTimescale: 1));
        avPlayer.play();
    }
}

extension VideoTrimmerViewController : ABVideoRangeSliderDelegate {
    func didChangeValue(videoRangeSlider: ABVideoRangeSlider, startTime: Float64, endTime: Float64) {
        
    }
    
    func indicatorDidChangePosition(videoRangeSlider: ABVideoRangeSlider, position: Float64) {
        //avPlayer.seek(to: CMTime(
    }
}
