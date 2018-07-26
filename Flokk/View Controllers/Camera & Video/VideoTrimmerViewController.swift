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
    
    var startTime: Double! = 0
    var endTime: Double! = 6
    
    var progressTimer: Timer!
    
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
        rangeSlider.setStartPosition(seconds: 0)
        rangeSlider.setEndPosition(seconds: 6) // What if it's not long enough?
        
        // Create and start a timer to update the progress indicator, wherever the video is currently
        progressTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(VideoTrimmerViewController.updateProgressIndicator), userInfo: nil, repeats: true)
        progressTimer.fire()
        
        self.videoEnded()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        avPlayer.pause()
        progressTimer.invalidate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func videoEnded() {
        avPlayer.seek(to: CMTime(seconds: startTime, preferredTimescale: 1000));
        avPlayer.play();
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // segue for going back?
    }
}

extension VideoTrimmerViewController : ABVideoRangeSliderDelegate {
    func didChangeValue(videoRangeSlider: ABVideoRangeSlider, startTime: Float64, endTime: Float64) {
        self.startTime = startTime
        self.endTime = endTime
        
        let currentTime = self.avPlayer.currentTime().seconds
        
        // If where the user seeked to is out of bounds of the start and end time
        // restart the playback to the start of the trimmer
        if currentTime > startTime && currentTime < endTime {
        } else {
            avPlayer.seek(to: CMTimeMakeWithSeconds(startTime, 1000))
        }
    }
    
    func indicatorDidChangePosition(videoRangeSlider: ABVideoRangeSlider, position: Float64) {
        if position > 0 {
            //progressTimer.invalidate()
            //avPlayer.seek(to: CMTimeMakeWithSeconds(position * 100, 100))
            //progressTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(VideoTrimmerViewController.updateProgressIndicator), userInfo: nil, repeats: true)
            //progressTimer.fire()
        }
    }
    
    // Update the progress indicator's location
    @objc func updateProgressIndicator() {
        let currentTime = self.avPlayer.currentTime().seconds
        print("\(currentTime) Start: \(startTime!) End: \(endTime!)")
        
        if currentTime > startTime && currentTime < endTime {
            self.rangeSlider.updateProgressIndicator(seconds: currentTime)
        }
        
        // Also check if the avplayer has reached the endTime
        // If so, restart the video to play at startTime
        if currentTime >= endTime {
            self.videoEnded()
        }
    }
}
