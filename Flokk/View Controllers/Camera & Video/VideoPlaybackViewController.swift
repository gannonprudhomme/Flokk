import UIKit
import AVFoundation

class VideoPlaybackViewController: UIViewController {
    
    var avPlayer: AVPlayer!
    var avPlayerLayer: AVPlayerLayer!
    
    var videoURL: URL!
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var doneButton: UIButton!
    
    var uploadPostDelegate: UploadPostDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addVideo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.restartVideo), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func donePressed(_ sender: Any) {
        // Upload the video to the current feed
        uploadPostDelegate.uploadPost(fileID: "file ID")
        
        // Get a preview image(of diff sizes?)
        self.dismiss(animated: true, completion: nil)
    }
    
    func addVideo() {
        avPlayer = AVPlayer()
        
        // Add the callback function to the av player for looping the video once it's ended
        NotificationCenter.default.addObserver(self, selector: #selector(self.restartVideo), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem)
        
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = self.videoView.bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.videoView.layer.insertSublayer(avPlayerLayer, at: 0)
        
        view.layoutIfNeeded()
        
        let playerItem = AVPlayerItem(url: videoURL as URL)
        avPlayer.replaceCurrentItem(with: playerItem)
        
        avPlayer.play()
    }
    
    // Callback function for when the video ends
    // Activates the replay button, or loops again automatically
    @objc func restartVideo() {
        // If the player isn't loaded or if we're not in view, skip
        if avPlayer != nil {
            avPlayer.seek(to: CMTime(seconds: 0, preferredTimescale: 1000));
            avPlayer.play();
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}
