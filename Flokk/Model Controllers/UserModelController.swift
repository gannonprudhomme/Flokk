//
//  UserModelController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 12/21/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import Foundation
import UIKit
import Promises

// Contains a global instance of all of the users within the app
// Also provides functions to load i, "~> 3.0"n users given their uid (and other parameters)
// Its purpose is basically that it prevents view controllers from a having to have to deal with retrieveing user data by themselves
class UserModelController {
    var uid: String
    var handle: String?
    var fullName: String?
    // var email: String?
    
    var profilePhoto: UIImage?
    
    var groups: [String]? // List of the uid's for the groups this user is in
    
    init(uid: String) {
        self.uid = uid
        self.handle = nil
        self.fullName = nil
        
        self.profilePhoto = nil
    }
    
    
    
    func loadUser(uid: String) {
        
    }
    
    // function convertToDict() -> [String : Any] { } // Is this necessary/in the right place?
}
