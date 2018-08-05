//
//  VerifyNumberViewController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 8/4/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import UIKit

// Used for signing in and signing up
class VerifyNumberViewController: UINavigationController {
    @IBOutlet weak var codeField: UITextField! // Verification Code
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
}
