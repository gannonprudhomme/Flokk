//
//  SettingsViewController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 8/13/18.
//  Copyright © 2018 Gannon Prudhomme. All rights reserved.
//

import UIKit
import FirebaseAuth

class UserSettingsViewController: UIViewController {
    @IBOutlet weak var profilePhotoButton: UIButton!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        
        // Crop the profile photo view to a circle
        profilePhotoButton.imageView?.layer.cornerRadius = profilePhotoButton.bounds.width / 2
        profilePhotoButton.clipsToBounds = true
        profilePhotoButton.contentMode = .scaleAspectFill
        
        profilePhotoButton.setImage(mainUser.profilePhoto, for: .normal)
        fullNameLabel.text = mainUser.fullName
        handleLabel.text = mainUser.handle
        emailLabel.text = Auth.auth().currentUser?.email
        
        phoneNumberLabel.text = "281-000-0000"
        
        // Save button is only shown if the information has been changed/updated
        saveButton.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Change profile photo
    @IBAction func profilePhotoPressed(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    // Upload the new profile photo
    @IBAction func donePressed(_ sender: Any) {
        let newProfilePhoto = profilePhotoButton.imageView?.image
        
        // Upload the new profile photo
        storage.child("users").child(mainUser.uid).child("profilePhoto.jpg").putData((newProfilePhoto?.convertJpegToData())!)
        
        // Set the profile photo property for the local user
        mainUser.profilePhoto = newProfilePhoto
    }
    
    @IBAction func logOutPressed(_ sender: Any) {
        // Create an alert
        let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        
        let confirmActionButton = UIAlertAction(title: "Confirm", style: .default, handler: { (_) in
            do {
                try Auth.auth().signOut()
                mainUser = nil
                
                self.performSegue(withIdentifier: "settingsToSignUpSegue", sender: nil)
            } catch let error {
                print(error)
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // Add the actions to the alert
        alert.addAction(cancelAction)
        alert.addAction(confirmActionButton)
        
        // Present the alert, causing it to pop up on screen
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Image Picker Function
extension UserSettingsViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            // Only show the save button if the profile photo has changed
            saveButton.isHidden = false
            profilePhotoButton.setImage(pickedImage, for: UIControlState.normal)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
