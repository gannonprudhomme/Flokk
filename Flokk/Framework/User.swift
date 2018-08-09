//
//  User.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 8/7/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import Foundation
import UIKit

// Contains all of the data for the users in Flokk
// A user will *always* have at least their UID
class User {
    var uid: String
    var handle: String?
    //var email: String? // Don't see why we would need access to the email
    
    // Should profilePhoto be an image or a link to the image?
    var profilePhoto: URL?
    
    // Only needed for the main user
    var groups = [Group]()
    
    // Empty user with nothing loaded
    init(uid: String) {
        self.uid = uid
    }
    
    init(uid: String, handle: String) {
        self.uid = uid
        self.handle = handle
    }
}
