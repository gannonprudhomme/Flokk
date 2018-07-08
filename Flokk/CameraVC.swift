////*
////  CameraVC.swift
////  Flokk Basic
////
////  Created by Jared Heyen on 7/7/18.
////  Copyright © 2018 Heyen Enterprises. All rights reserved.
////
//
//import UIKit
//import AVFoundation
//
//class CameraVC: UIViewController
//{
//    var captureSession = AVCaptureSession() //  Captures Image
//
//    //  Decide which camera to use
//    var backFacingCamera: AVCaptureDevice?
//    var frontFacingCamera: AVCaptureDevice?
//    var currentDevice: AVCaptureDevice?
//
//    //  Output device
//    var imageOutput: AVCapturePhotoOutput?
//    var stillImage: UIImage?
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        //  Setup to take photo in full resolution
//        captureSession.sessionPreset = AVCaptureSession.Preset.photo
//
//
//        let devices = AVCaptureDevice.devices(for: AVMediaTypeVideo) as!
//            [AVCaptureDevice]
//        for device in devices {
//            if device.position = .back {
//                backFacingCamera = device
//            } else if device.position == .front {
//                frontFacingCamera = device
//            }
//        }
//
//        //  Default device
//        currentDevice = backFacingCamera
//
//        //  Configure with output to capture still image
//        stillImageOutput = AVCaptureStillImage
//
//        do {
//            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)
//        } catch let error {
//            print (error)
//        }
//}
//
//}

