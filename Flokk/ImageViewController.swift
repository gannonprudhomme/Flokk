//
//  ImageViewController.swift
//  ViewController.swift
//  Flokk Basic
//
//  Created by Jared Heyen on 7/7/18.
//  Copyright © 2018 Heyen Enterprises. All rights reserved.
//


import UIKit

class ImageViewController : UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = image
    }
    
    @IBAction func closeButtonDidTap () {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func save(sender: UIButton) {
        guard let imageToSave = image else {
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil)
        dismiss(animated: false, completion: nil)
    }
}



















