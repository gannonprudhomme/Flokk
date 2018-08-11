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
                    
                    // All the user loading is done within the Groups VC anyways
                    self.performSegue(withIdentifier: "signInToGroupsSegue", sender: nil)
                    
                    /*
                    // Get the user data from the database
                    database.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                        if let value = snapshot.value as? NSDictionary {
                            let handle = value["handle"] as! String
                            
                            // Initialize the groups as well?
                            if let groups = value["groups"] as? [String : String] {
                                // Iterate over all of the groups
                                for groupID in groups.keys {
                                    let groupName = groups[groupID]
                                    let group = Group(uid: groupID, name: groupName!)
                                    
                                    group.requestGroupIcon(completion: { (icon) in
                                        if let icon = icon {
                                            group.setIcon(icon: icon)
                                        }
                                    })
                                    
                                    // Initialize the group and add it to the user's groups array
                                    mainUser.groups.append(Group(uid: groupID, name: groupName!))
                                }
                            }
                            
                            mainUser = User(uid: uid, handle: handle)
                            
                            // TODO: Get the profile photo from storage HERE
                            
                            print("Signed In successfully")
                            
                            // Segue to groups, don't need to pass anything
                            self.performSegue(withIdentifier: "signInToGroupsSegue", sender: nil)
                        }
                    }) */
                }
            } else {
                print(error?.localizedDescription)
                return
            }
        })
    }
}
