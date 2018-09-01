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
    
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailField.keyboardAppearance = .dark
        passwordField.keyboardAppearance = .dark
        //emailField.becomeFirstResponder()
        
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
                    
                    // All the user loading is done within the Groups VC anyways
                    self.performSegue(withIdentifier: "signInToGroupsSegue", sender: nil)
                }
            } else {
                print(error?.localizedDescription)
                return
            }
        })
    }
}
