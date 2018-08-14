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
    @IBOutlet weak var profilePhotoView: UIImageView!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Crop the profile photo view to a circle
        profilePhotoView.layer.cornerRadius = profilePhotoView.bounds.width / 2
        profilePhotoView.clipsToBounds = true
        
        profilePhotoView.image = mainUser.profilePhoto
        fullNameLabel.text = mainUser.fullName
        handleLabel.text = mainUser.handle
        emailLabel.text = Auth.auth().currentUser?.email
        
        phoneNumberLabel.text = "281-000-0000"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func logOutPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            
            performSegue(withIdentifier: "settingsToSignUpSegue", sender: nil)
        } catch let error {
            print(error)
        }
    }
}
