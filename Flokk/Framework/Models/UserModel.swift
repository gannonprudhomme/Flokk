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
    var uid: String // Unique Identifier for this User, used to index these groups for quick access in UsersController
    var handle: String? // The handle, or username of the user
    var fullName: String? // The full name of the user
    var email: String? // Is this necessary to ever have loaded in?
    
    var profilePhoto: UIImage?
    
    var groups: [String]? // Array of uids for the groups the user is in
    
    // Constructor
    init(uid: String) {
        self.uid = uid
        self.groups = [String]()
        
        // If the UID has a space in it, some sort of error should be thrown
    }
    
    // Put this in UserModelController
    // function convertToDict() -> [String : Any] { } // Is this necessary/in the right place?
}
