//
//  VideoTrimmerViewController.swift
//  Flokk
//
//  Created by Gannon Prudomme on 7/10/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import UIKit
import AVFoundation

class VideoTrimmerViewController: UIViewController {
    @IBOutlet weak var videoCanvasView: UIView!
    
    var videoURL: URL!
    
    var avPlayer: AVPlayer!
    var avPlayerLayer: AVPlayerLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        avPlayer = AVPlayer()
        
        // Add the callback function to the av player that causes it to loop
        NotificationCenter.default.addObserver(self, selector: #selector(VideoTrimmerViewController.videoEnded), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem)
        
        // Set up the AVPlayer to play the video
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = videoCanvasView.bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoCanvasView.layer.insertSublayer(avPlayerLayer, at: 0)
        
        view.layoutIfNeeded()
        
        let playerItem = AVPlayerItem(url: videoURL as URL)
        avPlayer.replaceCurrentItem(with: playerItem)
        
        // Start playing the video
        avPlayer.play()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func videoEnded() {
        avPlayer.seek(to: CMTime(seconds: 0, preferredTimescale: 1));
        avPlayer.play();
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
