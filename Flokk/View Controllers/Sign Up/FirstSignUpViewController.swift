//
//  FirstSignUpViewController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 8/4/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

// For now, purpose is to just pass on data to the SecondSignUp VC
class FirstSignUpViewController: UIViewController {
    @IBOutlet weak var fullNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func continuePressed(_ sender: Any) {
        // Check if the credientials are fine
        let password = passwordField.text!
        let fullName = fullNameField.text!
        let email = emailField.text!
        
        // Change these to something legitamate
        if email.count > 0 && password.count > 0 {
            performSegue(withIdentifier: "firstToSecondSignUpSegue", sender: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "firstToSecondSignUpSegue" {
            if let vc = segue.destination as? SecondSignUpViewController {
                vc.email = emailField.text!
                vc.password = passwordField.text!
                vc.fullName = fullNameField.text!
            }
        }
    }
}
