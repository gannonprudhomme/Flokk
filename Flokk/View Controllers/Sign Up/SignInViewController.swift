//
//  SignInViewController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 8/7/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignInViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func signInPressed(_ sender: Any) {
        let email = emailField.text!
        let password = passwordField.text!
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (authResult, error) in
            if error == nil {
                if let user = authResult?.user {
                    let uid = user.uid
                    
                    // Get the user data from the database
                    database.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                        if let value = snapshot.value as? NSDictionary {
                            let handle = value["handle"] as! String
                            
                            mainUser = User(uid: uid, handle: handle)
                            
                            // Get the profile photo from storage
                            
                            print("Signed In successfully")
                        }
                    })
                }
            } else {
                print(error?.localizedDescription)
                return
            }
        })
    }
}
