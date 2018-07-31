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
    fileprivate var trimmedVideoURL: URL!
    
    var avPlayer: AVPlayer!
    var avPlayerLayer: AVPlayerLayer!
    
    var startTime: Double! = 0
    var endTime: Double! = 6
    
    var progressTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addVideo()
        
        // Video Range Slider set up
        rangeSlider.setVideoURL(videoURL: videoURL)
        rangeSlider.delegate = self
        rangeSlider.minSpace = 6
        rangeSlider.maxSpace = 6
        rangeSlider.setStartPosition(seconds: 0)
        rangeSlider.setEndPosition(seconds: 6) // What if it's not long enough?
        
        // Why do we need to do this here
        restartVideo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //addVideo()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        avPlayer.pause()
        
        // Would have to create avplayer in viewDidAppear in order to do below
        //removeVideo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addVideo() {
        avPlayer = AVPlayer()
        
        // Add the callback function to the AVPlayer to make it loop
        NotificationCenter.default.addObserver(self, selector: #selector(VideoTrimmerViewController.restartVideo), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem)
        
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
        
        // Create and start a timer to update the progress indicator, wherever the video is currently
        progressTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.updateProgressIndicator), userInfo: nil, repeats: true)
        progressTimer.fire()
    }
    
    func removeVideo() {
        if avPlayer != nil {
            avPlayer.pause()
            avPlayerLayer.removeFromSuperlayer()
            avPlayer = nil
        }
        
        progressTimer.invalidate()
    }
    
    // Loops the video once it has ended
    @objc func restartVideo() {
        if avPlayer != nil {
            avPlayer.seek(to: CMTime(seconds: startTime, preferredTimescale: 1000));
            avPlayer.play();
        }
    }
    
    @IBAction func doneTrimmingPressed(_ sender: Any) {
        // Crop the video
        cropVideo(sourceURL: self.videoURL, startTime: self.startTime, endTime: self.endTime, completion: { (outputURL) in
            // Once done cropping the video, segue to the playback VC(for now)
            DispatchQueue.main.async {
                self.trimmedVideoURL = outputURL
                self.performSegue(withIdentifier: "playbackFromTrimSegue", sender: self)
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // segue for going back?
        if segue.identifier == "playbackFromTrimSegue" {
            if let vc = segue.destination as? VideoPlaybackViewController {
                vc.videoURL = self.trimmedVideoURL
            }
        }
    }
}

extension VideoTrimmerViewController {
    // Consider putting this in a helper function class
    // From: https://stackoverflow.com/questions/35696188/how-to-trim-a-video-in-swift-for-a-particular-time , answer 2
    func cropVideo(sourceURL: URL, startTime: Double, endTime: Double, completion: ((_ outputUrl: URL) -> Void)? = nil) {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let asset = AVAsset(url: sourceURL)
        let length = Float(asset.duration.value) / Float(asset.duration.timescale)
        print("video length: \(length) seconds")
        
        var outputURL = documentDirectory.appendingPathComponent("output")
        do {
            try fileManager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
            outputURL = outputURL.appendingPathComponent("\(sourceURL.lastPathComponent).mp4")
        }catch let error {
            print(error)
        }
        
        //Remove existing file
        try? fileManager.removeItem(at: outputURL)
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else { return }
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        
        let timeRange = CMTimeRange(start: CMTime(seconds: startTime, preferredTimescale: 1000),
                                    end: CMTime(seconds: endTime, preferredTimescale: 1000))
        
        exportSession.timeRange = timeRange
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                print("exported at \(outputURL)")
                completion?(outputURL)
            case .failed:
                print("failed \(exportSession.error.debugDescription)")
            case .cancelled:
                print("cancelled \(exportSession.error.debugDescription)")
            default: break
            }
        }
    }
}

// MARK: Delegate functions for ABVideoRangeSlider
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
    // (not a delegate function)
    @objc func updateProgressIndicator() {
        if avPlayer != nil {
            let currentTime = self.avPlayer.currentTime().seconds
            //print("\(currentTime) Start: \(startTime!) End: \(endTime!)")
            
            if currentTime > startTime && currentTime < endTime {
                self.rangeSlider.updateProgressIndicator(seconds: currentTime)
            }
            
            // Also check if the avplayer has reached the endTime
            // If so, restart the video to play at startTime
            if currentTime >= endTime {
                self.restartVideo()
            }
        }
    }
}
