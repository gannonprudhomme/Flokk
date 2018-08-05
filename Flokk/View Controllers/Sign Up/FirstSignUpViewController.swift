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

class FirstSignUpViewController: UINavigationController {
    @IBOutlet weak var phoneNumberField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func continuePressed(_ sender: Any) {
        let phoneNum = phoneNumberField.text!
        
        // Check if the phone number field is long enough
        // Would have to change for out-of-US phone numbers
        if phoneNumberField.text?.count == 10 {
            // Attempt to verify the phone number
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNum, uiDelegate: nil, completion: { (verificationID, error) in
                if let error = error { // If there was an error
                    print("Error in phone verification \(error.localizedDescription)")
                    return
                } else {
                    UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                }
            })
        } else { // Not enough digits in phone number
            
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}
