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
import RecordButton

let maxRecordDuration: CGFloat! = 6 // Seconds

// Should split up by extensions
class CameraViewController : UIViewController {
    @IBOutlet weak var recordButton: RecordButton!
    //@IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var photoLibraryButton: UIButton!
    
    @IBOutlet weak var previewView: UIView!
    //var previewView: UIView!
    
    // File URL for the recorded video, used when transitioning to the preview VC
    var videoURL: URL!
    
    // For recording with the camera button
    var longPressGestureRecognizer: UILongPressGestureRecognizer?
    
    // For counting recording duration, sent to RecordButton
    var progressTimer: Timer!
    var progress: CGFloat! = 0

    let imagePicker = UIImagePickerController()
    
    var isFlashOn = false
    
    var uploadPostDelegate: UploadPostDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //flashButton.isHidden = true
        
        // Configure the capture session
        NextLevel.shared.delegate = self
        NextLevel.shared.deviceDelegate = self
        NextLevel.shared.videoDelegate = self
        NextLevel.shared.photoDelegate = self
        
        //NextLevel.shared.videoConfiguration.maximumCaptureDuration = CMTimeMake(5, 600)
        NextLevel.shared.videoConfiguration.bitRate = 5500000
        NextLevel.shared.audioConfiguration.bitRate = 96000
        
        // Only stops if there are atleast 2 clips
        NextLevel.shared.videoConfiguration.maximumCaptureDuration = CMTimeMakeWithSeconds(Double(maxRecordDuration), 1)
        
        // Configure the preview layer for the camera
        let screenBounds = UIScreen.main.bounds
        
        //previewView = UIView(frame: screenBounds)
        if let previewView = self.previewView {
            previewView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            previewView.backgroundColor = UIColor(named: "Flokk Navy")
            NextLevel.shared.previewLayer.frame = screenBounds
            previewView.layer.addSublayer(NextLevel.shared.previewLayer)
            self.view.addSubview(previewView)
        }
        
        recordButton.progressColor = UIColor(named: "Flokk Teal")
        recordButton.closeWhenFinished = false
        
        self.view.bringSubview(toFront: photoLibraryButton)
        self.view.bringSubview(toFront: flashButton)
        self.view.bringSubview(toFront: recordButton)
        
        // Initialize the long press gesture recognizer for recording
        self.longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGestureRecognizer(_:)))
        if let gestureRecognizer = self.longPressGestureRecognizer {
            gestureRecognizer.delegate = self
            gestureRecognizer.minimumPressDuration = 0.05
            gestureRecognizer.allowableMovement = 10.0
            recordButton.addGestureRecognizer(gestureRecognizer)
        }
        
        // Set up Image Picker
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = ["public.movie"]
        imagePicker.allowsEditing = false // Skip the built in "editing" step
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reset the record button incase the user goes back from VideoPlaybackVC
        self.progress = 0
        self.recordButton.setProgress(progress)
        
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
        
        // Reset the record button incase the user goes back from VideoPlaybackVC
        //self.progress = 0
        //self.recordButton.setProgress(progress)
    }
    
    @IBAction func photoLibraryPressed(_ sender: Any) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    // Not working
    @IBAction func flashPressed(_ sender: Any) {
        // Toggle flash
        if NextLevel.shared.isFlashAvailable {
            if self.isFlashOn {
                NextLevel.shared.flashMode = .off
                self.isFlashOn = false
            } else {
                NextLevel.shared.flashMode = .on
                self.isFlashOn = true
            }
        }
    }
    
    @IBAction func switchCameraPressed(_ sender: Any) {
        NextLevel.shared.flipCaptureDevicePosition()
    }
    
    @IBAction func exitButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass the video URL to the playback/finalization screen
        if segue.identifier == "doneRecordingSegue" {
            if let vc = segue.destination as? VideoPlaybackViewController {
                vc.videoURL = self.videoURL
                vc.uploadPostDelegate = uploadPostDelegate
                
            }
        } else if segue.identifier == "trimVideoSegue" {
            if let vc = segue.destination as? VideoTrimmerViewController {
                vc.videoURL = self.videoURL
                vc.uploadPostDelegate = uploadPostDelegate
            }
        }
    }
}

// MARK: - Camera functions
extension CameraViewController {
    internal func startRecording() {
        NextLevel.shared.record()
        
        self.progressTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(CameraViewController.updateProgress), userInfo: nil, repeats: true)
        progressTimer.fire()
    }
    
    internal func pauseRecording() {
        NextLevel.shared.pause()
        
        progressTimer.invalidate()
    }
    
    // Handle the recorded video
    internal func endRecording() {
        if let session = NextLevel.shared.session {
            // If there are multiple clips, attempt to merge them
            if session.clips.count > 1 {
                session.mergeClips(usingPreset: AVAssetExportPresetHighestQuality, completionHandler: { (url: URL?, error: Error?) in
                    // Retrieve the merged file URL
                    if let url = url {
                       self.videoURL = url
                        
                        // Segue to the next view only when the clips are done merging
                        self.performSegue(withIdentifier: "doneRecordingSegue", sender: self)
                    } else if let _ = error {
                        print("failed to merge clips at the end of capture \(String(describing: error))")
                    }
                })
            // If there was only one clip?
            } else if let lastClipURL = session.lastClipUrl {
                self.videoURL = lastClipURL
                
                self.performSegue(withIdentifier: "doneRecordingSegue", sender: self)
            // When would this be called?
            } else if session.currentClipHasStarted {
                print("clip has started")
                session.endClip(completionHandler: { (clip, error) in
                    if error == nil {
                        let url = clip?.url
                        self.videoURL = url
                        
                    } else {
                        print("Error in ending recording: \(error)")
                    }
                })
            } else {
                
            }
        }
    }
}

// MARK: Record Button Delegate Functions
extension CameraViewController {
    @objc func updateProgress() {
        progress = progress + (CGFloat(0.05) / maxRecordDuration)
        recordButton.setProgress(progress)
        
        // Recording has been completed
        if progress >= 1 {
            progressTimer.invalidate()
        }
        
    }
}

// MARK: Image Picker Delegate Functions
extension CameraViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        
        videoURL = info[UIImagePickerControllerMediaURL] as! URL
        
        performSegue(withIdentifier: "trimVideoSegue", sender: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: Gesture Recognizer
// For holding the record button and detecting when we're done recording(?)
extension CameraViewController : UIGestureRecognizerDelegate {
    @objc internal func handleLongPressGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        // Check if we've recorded enough video to go to the finalization screen
        if let session = NextLevel.shared.session {
            if (session.totalDuration.seconds) < Double(maxRecordDuration) {
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
                    self.pauseRecording()
                    fallthrough
                default:
                   // print("Default: \(session.totalDuration.seconds)")
                    
                    break
                }
            } else { // If we've reached the max duration, switch to the "finalization" stage
                print("Max duration reached")
                //self.endRecording()
                //self.performSegue(withIdentifier: "doneRecordingSegue", sender: self)
            }
        } else {
            print("unable to access session")
        }
        
        //print(NextLevel.shared.session?.totalDuration.seconds)
    }
}

// MARK: - NextLevel delegates for video capture
// Consider moving these to a separate file, at least the unused ones
extension CameraViewController : NextLevelDelegate {
    // Permissions
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
    func nextLevelSessionDidStart(_ nextLevel: NextLevel) {}
    func nextLevelSessionDidStop(_ nextLevel: NextLevel) {}
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
        self.endRecording()
    }
    
    func nextLevel(_ nextLevel: NextLevel, didStartClipInSession session: NextLevelSession) {
        print("Started Clip \((NextLevel.shared.session?.totalDuration.seconds)!)")
    }
    
    func nextLevel(_ nextLevel: NextLevel, didCompleteClip clip: NextLevelClip, inSession session: NextLevelSession) {
        print("Completed Clip")
    }
    
    func nextLevel(_ nextLevel: NextLevel, didUpdateVideoZoomFactor videoZoomFactor: Float) {}
    func nextLevel(_ nextLevel: NextLevel, willProcessRawVideoSampleBuffer sampleBuffer: CMSampleBuffer, onQueue queue: DispatchQueue) {}
    func nextLevel(_ nextLevel: NextLevel, renderToCustomContextWithImageBuffer imageBuffer: CVPixelBuffer, onQueue queue: DispatchQueue) {}
    func nextLevel(_ nextLevel: NextLevel, willProcessFrame frame: AnyObject, pixelBuffer: CVPixelBuffer, timestamp: TimeInterval, onQueue queue: DispatchQueue) {}
    func nextLevel(_ nextLevel: NextLevel, didSetupVideoInSession session: NextLevelSession) {}
    func nextLevel(_ nextLevel: NextLevel, didSetupAudioInSession session: NextLevelSession) {}
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
