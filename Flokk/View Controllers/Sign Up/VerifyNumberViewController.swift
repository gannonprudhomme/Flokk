//
//  VerifyNumberViewController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 8/4/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import UIKit
import FirebaseAuth

// Used for signing in and signing up
class VerifyNumberViewController: UINavigationController {
    @IBOutlet weak var codeField: UITextField! // Verification Code
    
    var phoneNumber: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func codeEntered(_ sender: Any) {
        
    }
    
    @IBAction func continuePressed(_ sender: Any) {
        // Authenticate the phone number by verifying the code
        
        authenticateUser(verificationCode: codeField.text!, completion: { (completed) in
            if let parentVC = self.parent as? FirstSignUpViewController {
                // Segue to the second sign up
                
                
            } else {
                
            }
        })
    }
    
    func authenticateUser(verificationCode: String, completion: @escaping (Bool) -> Void) {
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID!, verificationCode: verificationCode)
        
        Auth.auth().signInAndRetrieveData(with: credential, completion: { (authResult, error) in
            if let error = error {
                print(error)
                return
            }
            
            // User is signed in
            print("User signed in successfully, auth result: \(authResult)")
            completion(true)
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "verifyNumberToSecondSignUpSegue" {
            if let vc = segue.destination as? SecondSignUpViewController {
                
            }
        }
    }
}
