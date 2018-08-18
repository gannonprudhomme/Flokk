//
//  SecondSignUpViewController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 8/7/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SecondSignUpViewController: UIViewController {
    @IBOutlet weak var profilePhotoButton: UIButton!
    @IBOutlet weak var handleField: UITextField!
    
    var email: String!
    var fullName: String!
    var password: String!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        handleField.becomeFirstResponder()
        
        profilePhotoButton.contentMode = .scaleAspectFit
        profilePhotoButton?.layer.cornerRadius = (self.profilePhotoButton?.frame.size.width)! / 2
        profilePhotoButton?.clipsToBounds = true

        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func addProfilePhotoPressed(_ sender: Any) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func registerPressed(_ sender: Any) {
        // Create the account in the database
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (authResult, error) in
            if error == nil {
                if let user = authResult?.user {
                    let uid = user.uid
                    
                    // Set the user database values
                    let userRef = database.child("users").child(uid)
                    userRef.child("email").setValue(self.email)
                    userRef.child("handle").setValue(self.handleField.text!)
                    userRef.child("name").setValue(self.fullName)
                    
                    let data = self.profilePhotoButton.imageView?.image!.convertJpegToData()
                    
                    // Upload the profile photo picked by the user
                    storage.child("users").child(uid).child("profilePhoto.jpg").putData(data!, metadata: nil, completion: { (metadata, error) in
                        if error == nil {
                            // Create the main user, to be used throughout the app
                            mainUser = User(uid: uid, handle: self.handleField.text!)
                            
                            print("registered user")
                            
                            // Now go to the groups view, nothing to transfer to it
                            self.performSegue(withIdentifier: "signUpToGroupsSegue", sender: nil)
                        } else { // Throw an error if there was one
                            print("Storage error: \(error!.localizedDescription)")
                            return
                        }
                    })
                }  
            } else {
                print("Auth error: \(error!.localizedDescription)")
                return
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
}

extension SecondSignUpViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profilePhotoButton.setImage(pickedImage, for: UIControlState.normal)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
