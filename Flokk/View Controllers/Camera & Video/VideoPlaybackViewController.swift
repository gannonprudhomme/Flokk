import UIKit
import AVFoundation

class VideoPlaybackViewController: UIViewController {
    
    let avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!
    
    var videoURL: URL!
    
    @IBOutlet weak var videoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add the callback function to the av player
        NotificationCenter.default.addObserver(self, selector: #selector(VideoPlaybackViewController.videoEnded), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem)
        
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = view.bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoView.layer.insertSublayer(avPlayerLayer, at: 0)
        
        view.layoutIfNeeded()
        
        let playerItem = AVPlayerItem(url: videoURL as URL)
        avPlayer.replaceCurrentItem(with: playerItem)
        
        avPlayer.play()
    }
    
    // Callback function for when the video ends
    // Activates the replay button, or loops again automatically
    @objc func videoEnded() {
        avPlayer.seek(to: CMTime(seconds: 0, preferredTimescale: 1));
        avPlayer.play();
    }
}
