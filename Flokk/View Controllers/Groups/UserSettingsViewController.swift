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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Crop the profile photo view to a circle
        profilePhotoButton.imageView?.layer.cornerRadius = profilePhotoButton.bounds.width / 2
        profilePhotoButton.clipsToBounds = true
        
        profilePhotoButton.imageView?.image = mainUser.profilePhoto
        fullNameLabel.text = mainUser.fullName
        handleLabel.text = mainUser.handle
        emailLabel.text = Auth.auth().currentUser?.email
        
        phoneNumberLabel.text = "281-000-0000"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func logOutPressed(_ sender: Any) {
        // Create an alert
        let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        
        let confirmActionButton = UIAlertAction(title: "Confirm", style: .default, handler: { (_) in
            do {
                try Auth.auth().signOut()
                
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
