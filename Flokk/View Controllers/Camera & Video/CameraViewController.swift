//
//  CameraViewController.swift
//  ViewController.swift
//  Flokk Basic
//
//  Created by Jared Heyen on 7/7/18.
//  Copyright © 2018 Heyen Enterprises. All rights reserved.
//


import UIKit
import AVKit
import NextLevel
import Photos

class CameraViewController : UIViewController {
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    var previewView: UIView!
    
    var videoURL: URL!
    
    var recording = false
    
    // For recording with the camera button
    var longPressGestureRecognizer: UILongPressGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the capture session
        NextLevel.shared.delegate = self
        NextLevel.shared.deviceDelegate = self
        NextLevel.shared.videoDelegate = self
        NextLevel.shared.photoDelegate = self
        
        //NextLevel.shared.videoConfiguration.maximumCaptureDuration = CMTimeMake(5, 600)
        NextLevel.shared.videoConfiguration.bitRate = 5500000
        NextLevel.shared.audioConfiguration.bitRate = 96000
        
        // Configure the preview layer for the camera
        let screenBounds = UIScreen.main.bounds
        previewView = UIView(frame: screenBounds)
        if let previewView = self.previewView {
            previewView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            previewView.backgroundColor = UIColor.black
            NextLevel.shared.previewLayer.frame = previewView.bounds
            previewView.layer.addSublayer(NextLevel.shared.previewLayer)
            self.view.addSubview(previewView)
        }
        
        self.view.bringSubview(toFront: cameraButton)
        self.view.bringSubview(toFront: doneButton)
        
        
        // Initialize the long press gesture recognizer for recording
        self.longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGestureRecognizer(_:)))
        if let gestureRecognizer = self.longPressGestureRecognizer {
            gestureRecognizer.delegate = self
            gestureRecognizer.minimumPressDuration = 0.05
            gestureRecognizer.allowableMovement = 10.0
            cameraButton.addGestureRecognizer(gestureRecognizer)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Attempt to start the camera when the view appears
        // Fails on first launch, as authorization for camera & microphone is needed
        if NextLevel.shared.authorizationStatus(forMediaType: AVMediaType.video) == .authorized && NextLevel.shared.authorizationStatus(forMediaType: AVMediaType.audio) == .authorized {
            do {
                try NextLevel.shared.start()
            } catch let error {
                print("Error in authorizing camera: \(error)")
            }
        } else { // If not authorized, attempt to
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { result in })
            AVCaptureDevice.requestAccess(for: AVMediaType.audio, completionHandler: { result in
                
                // Once we've authorized both audio and video, attempt to start the camera again
                do {
                    try NextLevel.shared.start()
                } catch let error {
                    print("Error in authorizing camera: \(error)")
                }
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NextLevel.shared.stop()
    }
    
    // When the done button is pressed, temporary
    @IBAction func donePressed(_ sender: Any) {
        self.endRecording()
        performSegue(withIdentifier: "showVideoSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showVideoSegue" {
            if let vc = segue.destination as? VideoPlaybackViewController {
                vc.videoURL = self.videoURL
            }
        }
    }
}

// Camera functions
extension CameraViewController {
    internal func startRecording() {
        NextLevel.shared.record()
    }
    
    internal func pauseRecording() {
        NextLevel.shared.pause()
    }
    
    // Handle the recorded video
    internal func endRecording() {
        if let session = NextLevel.shared.session {
            if session.clips.count > 1 {
                session.mergeClips(usingPreset: AVAssetExportPresetHighestQuality, completionHandler: { (url: URL?, error: Error?) in
                    if let url = url {
                       self.videoURL = url
                    } else if let _ = error {
                        print("failed to merge clips at the end of capture \(String(describing: error))")
                    }
                })
            } else if let lastClipURL = session.lastClipUrl {
                print(lastClipURL)
                self.videoURL = lastClipURL
            } else if session.currentClipHasStarted {
                print("clip has started")
                session.endClip(completionHandler: { (clip, error) in
                    if error == nil {
                        var url = clip?.url
                        print(url)
                        self.videoURL = url
                        
                    } else {
                        print("Error in ending recording: \(error)")
                    }
                })
            }
        }
    }
}

extension CameraViewController : UIGestureRecognizerDelegate {
    @objc internal func handleLongPressGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            self.startRecording()
            // Zoom?
            break
        case .changed:
            // Zoom?
            break
        case .ended:
            fallthrough
        case .cancelled:
            fallthrough
        case .failed:
            print(NextLevel.shared.session?.totalDuration)
            print(NextLevel.shared.session?.currentClipDuration)
            self.pauseRecording()
            print("Done Recording")
            fallthrough
        default:
            break
        }
    }
}

// Delegates needed to use NextLevel for video recording
// Not even needed(at least initially)
// Consider moving this to a separate file?
extension CameraViewController : NextLevelDelegate {
    // Permissions
    // On launch,
    func nextLevel(_ nextLevel: NextLevel, didUpdateAuthorizationStatus status: NextLevelAuthorizationStatus, forMediaType mediaType: AVMediaType) {
        print("authorization update")
        // Check if already authorized
        if nextLevel.authorizationStatus(forMediaType: AVMediaType.video) == .authorized && nextLevel.authorizationStatus(forMediaType: AVMediaType.audio) == .authorized {
            do {
                try nextLevel.start()
            } catch let error {
                print("Camera authorization failed: \(error)")
            }
        } else {
            print("Some shit went wrong in didUpdateAuthorizationStatus)")
        }
    }
    
    func nextLevel(_ nextLevel: NextLevel, didUpdateVideoConfiguration videoConfiguration: NextLevelVideoConfiguration) {}
    func nextLevel(_ nextLevel: NextLevel, didUpdateAudioConfiguration audioConfiguration: NextLevelAudioConfiguration) {}
    func nextLevelSessionWillStart(_ nextLevel: NextLevel) {}
    
    func nextLevelSessionDidStart(_ nextLevel: NextLevel) {
        
    }
    func nextLevelSessionDidStop(_ nextLevel: NextLevel) {
        
    }
    
    func nextLevelSessionWasInterrupted(_ nextLevel: NextLevel) {}
    func nextLevelSessionInterruptionEnded(_ nextLevel: NextLevel) {}
    func nextLevelCaptureModeWillChange(_ nextLevel: NextLevel) {}
    func nextLevelCaptureModeDidChange(_ nextLevel: NextLevel) {}
}

extension CameraViewController : NextLevelDeviceDelegate {
    func nextLevelDevicePositionWillChange(_ nextLevel: NextLevel) {}
    func nextLevelDevicePositionDidChange(_ nextLevel: NextLevel) {}
    func nextLevel(_ nextLevel: NextLevel, didChangeDeviceOrientation deviceOrientation: NextLevelDeviceOrientation) {}
    func nextLevel(_ nextLevel: NextLevel, didChangeDeviceFormat deviceFormat: AVCaptureDevice.Format) {}
    func nextLevel(_ nextLevel: NextLevel, didChangeCleanAperture cleanAperture: CGRect) {}
    func nextLevelWillStartFocus(_ nextLevel: NextLevel) {}
    func nextLevelDidStopFocus(_ nextLevel: NextLevel) {}
    func nextLevelWillChangeExposure(_ nextLevel: NextLevel) {}
    func nextLevelDidChangeExposure(_ nextLevel: NextLevel) {}
    func nextLevelWillChangeWhiteBalance(_ nextLevel: NextLevel) {}
    func nextLevelDidChangeWhiteBalance(_ nextLevel: NextLevel) {}
}

extension CameraViewController : NextLevelVideoDelegate {
    // Called when recordings completed, specifically when it reaches a maximum duration
    func nextLevel(_ nextLevel: NextLevel, didCompleteSession session: NextLevelSession) {
        // End Capture
        print("Completed Session")
    }
    
    func nextLevel(_ nextLevel: NextLevel, didUpdateVideoZoomFactor videoZoomFactor: Float) {}
    func nextLevel(_ nextLevel: NextLevel, willProcessRawVideoSampleBuffer sampleBuffer: CMSampleBuffer, onQueue queue: DispatchQueue) {}
    func nextLevel(_ nextLevel: NextLevel, renderToCustomContextWithImageBuffer imageBuffer: CVPixelBuffer, onQueue queue: DispatchQueue) {}
    func nextLevel(_ nextLevel: NextLevel, willProcessFrame frame: AnyObject, pixelBuffer: CVPixelBuffer, timestamp: TimeInterval, onQueue queue: DispatchQueue) {}
    func nextLevel(_ nextLevel: NextLevel, didSetupVideoInSession session: NextLevelSession) {}
    func nextLevel(_ nextLevel: NextLevel, didSetupAudioInSession session: NextLevelSession) {}
    func nextLevel(_ nextLevel: NextLevel, didStartClipInSession session: NextLevelSession) {
        print("Started Clip")
    }
    func nextLevel(_ nextLevel: NextLevel, didCompleteClip clip: NextLevelClip, inSession session: NextLevelSession) {
        print("Completed Clip")
    }
    func nextLevel(_ nextLevel: NextLevel, didAppendVideoSampleBuffer sampleBuffer: CMSampleBuffer, inSession session: NextLevelSession) {}
    func nextLevel(_ nextLevel: NextLevel, didSkipVideoSampleBuffer sampleBuffer: CMSampleBuffer, inSession session: NextLevelSession) {}
    func nextLevel(_ nextLevel: NextLevel, didAppendVideoPixelBuffer pixelBuffer: CVPixelBuffer, timestamp: TimeInterval, inSession session: NextLevelSession) {}
    func nextLevel(_ nextLevel: NextLevel, didSkipVideoPixelBuffer pixelBuffer: CVPixelBuffer, timestamp: TimeInterval, inSession session: NextLevelSession) {}
    func nextLevel(_ nextLevel: NextLevel, didAppendAudioSampleBuffer sampleBuffer: CMSampleBuffer, inSession session: NextLevelSession) {}
    func nextLevel(_ nextLevel: NextLevel, didSkipAudioSampleBuffer sampleBuffer: CMSampleBuffer, inSession session: NextLevelSession) {}
    func nextLevel(_ nextLevel: NextLevel, didCompletePhotoCaptureFromVideoFrame photoDict: [String : Any]?) {}
}

extension CameraViewController : NextLevelPhotoDelegate {
    func nextLevel(_ nextLevel: NextLevel, willCapturePhotoWithConfiguration photoConfiguration: NextLevelPhotoConfiguration) {}
    func nextLevel(_ nextLevel: NextLevel, didCapturePhotoWithConfiguration photoConfiguration: NextLevelPhotoConfiguration) {}
    func nextLevel(_ nextLevel: NextLevel, didProcessPhotoCaptureWith photoDict: [String : Any]?, photoConfiguration: NextLevelPhotoConfiguration) {}
    func nextLevel(_ nextLevel: NextLevel, didProcessRawPhotoCaptureWith photoDict: [String : Any]?, photoConfiguration: NextLevelPhotoConfiguration) {}
    func nextLevelDidCompletePhotoCapture(_ nextLevel: NextLevel) {}
}