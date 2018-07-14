//
//  TempImagePickerViewController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 7/13/18.
//  Copyright © 2018 Gannon Prudhomme. All rights reserved.
//

import UIKit

class TempImagePickerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    var videoURL: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = ["public.movie"]
        imagePicker.allowsEditing = false

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        
        videoURL = info[UIImagePickerControllerMediaURL] as! URL
        
        performSegue(withIdentifier: "trimVideoSegue", sender: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "trimVideoSegue" {
            let vc = segue.destination as! VideoTrimmerViewController
            vc.videoURL = videoURL
        }
    }
    
    @IBAction func cameraRollPressed(_ sender: Any) {
        self.present(imagePicker, animated: false, completion: nil)
    }
}
