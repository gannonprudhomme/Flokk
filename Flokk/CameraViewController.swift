//
//  CameraViewController.swift
//  ViewController.swift
//  Flokk Basic
//
//  Created by Jared Heyen on 7/7/18.
//  Copyright © 2018 Heyen Enterprises. All rights reserved.
//


import UIKit
import AVFoundation

class CameraViewController : UIViewController {
    @IBOutlet weak var cameraButton: UIButton!
    
    // Represents the input device
    var captureSession = AVCaptureSession()
    
    // Camera inputs
    var backFacingCamera: AVCaptureDevice?
    var frontFacingCamera: AVCaptureDevice?
    var currentDevice: AVCaptureDevice?
    
    // output device
    var stillImageOutput: AVCapturePhotoOutput?
    
    var movieOutput: AVCaptureMovieFileOutput?;
    
    // For showing the user a preview of what the camera is recording
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    // double tap to switch from back to front facing camera
    var toggleCameraGestureRecognizer = UITapGestureRecognizer()
    
    var outputURL: URL!
    
    // Fixed video duration in seconds
    let videoDuration = 6
    
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        
        // Set the camera capture devices with their corresponding inputs
        let devices = AVCaptureDevice.devices(for: AVMediaType.video)
        for device in devices {
            if device.position == .back {
                backFacingCamera = device
            } else if device.position == .front {
                frontFacingCamera = device
            }
        }
        
        // default device
        currentDevice = frontFacingCamera
        
        movieOutput = AVCaptureMovieFileOutput()
        
        // configure the session with the output for capturing our still image
        stillImageOutput = AVCapturePhotoOutput()
        
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)
            
            captureSession.addInput(captureDeviceInput)
            captureSession.addOutput(movieOutput!)
            
            // set up the camera preview layer
            cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            view.layer.addSublayer(cameraPreviewLayer!)
            cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            cameraPreviewLayer?.frame = view.layer.frame
            
            view.bringSubview(toFront: cameraButton)
            
            captureSession.startRunning()
            
            // toggle the camera
            toggleCameraGestureRecognizer.numberOfTapsRequired = 2
            toggleCameraGestureRecognizer.addTarget(self, action: #selector(toggleCamera))
            view.addGestureRecognizer(toggleCameraGestureRecognizer)
        } catch let error {
            print(error)
        }
    }
    
    @IBAction func recordButtonPressed(_ sender: Any) {
        if movieOutput?.isRecording == false {
            let directory = NSTemporaryDirectory() as NSString
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            outputURL = URL(fileURLWithPath: path)
            
            // Start recording
            movieOutput?.startRecording(to: outputURL, recordingDelegate: self)
            
            // Start the timer to stop recording after specified duration
            timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.stopRecording), userInfo: nil, repeats: false)
        } /*else {
            // Stop recording
            movieOutput?.stopRecording()
        } */
    }
    
    @objc func videoWasSavedSuccessfully(_ video: String, didFinishSavingWithError error: NSError!, context: UnsafeMutableRawPointer) {
        if let theError = error {
            print("error = \(theError)");
        } else {
            print("Success");
        }
    }
    
    @objc private func toggleCamera() {
        // start the configuration change
        captureSession.beginConfiguration()
        
        let newDevice = (currentDevice?.position == . back) ? frontFacingCamera : backFacingCamera
        
        for input in captureSession.inputs {
            captureSession.removeInput(input as! AVCaptureDeviceInput)
        }
        
        let cameraInput: AVCaptureDeviceInput
        do {
            cameraInput = try AVCaptureDeviceInput(device: newDevice!)
        } catch let error {
            print(error)
            return
        }
        
        if captureSession.canAddInput(cameraInput) {
            captureSession.addInput(cameraInput)
        }
        
        currentDevice = newDevice
        captureSession.commitConfiguration()
    }
    
    // Callback function for timer to stop recording
    @objc private func stopRecording() {
        print("Stopping recording callback")
        movieOutput?.stopRecording()
        
        timer.invalidate()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Send the video file URL to the playback controller
        let vc = segue.destination as! VideoPlaybackViewController
        vc.videoURL = sender as! URL
    }
}

extension CameraViewController : AVCaptureFileOutputRecordingDelegate {
    // Called when the video is finished recording
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error != nil {
            print("Error in saving video: \(error?.localizedDescription)")
        } else {
            let videoRecorded = outputURL! as URL
            
            print(outputURL)
            
            performSegue(withIdentifier: "showVideo", sender: videoRecorded)
        }
    }
}
