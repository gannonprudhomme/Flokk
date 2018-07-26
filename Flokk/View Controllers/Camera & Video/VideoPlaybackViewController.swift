import UIKit
import AVFoundation

class VideoPlaybackViewController: UIViewController {
    
    let avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!
    
    var videoURL: URL!
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add the callback function to the av player
        NotificationCenter.default.addObserver(self, selector: #selector(VideoPlaybackViewController.videoEnded), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem)
        
        //videoURL = URL(string: "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8")
        
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = self.videoView.bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.videoView.layer.insertSublayer(avPlayerLayer, at: 0)
        
        view.layoutIfNeeded()
        
        let playerItem = AVPlayerItem(url: videoURL as URL)
        avPlayer.replaceCurrentItem(with: playerItem)
        
        avPlayer.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        avPlayer.pause()
    }
    
    // Callback function for when the video ends
    // Activates the replay button, or loops again automatically
    @objc func videoEnded() {
        avPlayer.seek(to: CMTime(seconds: 0, preferredTimescale: 1));
        avPlayer.play();
    }
    
    @IBAction func donePressed(_ sender: Any) {
        
    }
}
