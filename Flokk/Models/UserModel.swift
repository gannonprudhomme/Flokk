//
//  User.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 12/16/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import Foundation
import UIKit

class UserModel {
    var uid: String = ""
    var handle: String?
    var fullName: String?
    var email: String?
    
    var profilePhoto: UIImage?
    
    var groups = [String]() // Array of uids for the groups the user is in
    
    // Constructor
    init(uid: String) {
        self.uid = uid
    }
    
    // function convertToDict() -> [String : Any] { } // Is this necessary/in the right place?
}
