//
//  CameraViewController.swift
//  ViewController.swift
//  Flokk Basic
//
//  Created by Jared Heyen on 7/7/18.
//  Copyright © 2018 Heyen Enterprises. All rights reserved.
//


import UIKit
import NextLevel

class CameraViewController : UIViewController {
    @IBOutlet weak var cameraButton: UIButton!

    @IBOutlet weak var cameraRollButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.bringSubview(toFront: cameraRollButton)
        
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
}
