//
//  GroupsViewController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 8/7/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class GroupsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Auth.auth().currentUser != nil {
            // User is signed in
        } else {
            // No user is signed in, go to the sign in / sign up
            let vc = UIStoryboard(name: "SignUp", bundle: nil).instantiateViewController(withIdentifier: "SignUpNavigationController")
            present(vc, animated: false, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}
