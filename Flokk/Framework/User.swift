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
    var fullName: String?
    var email: String? // Don't see why we would need access to the email
    
    // Should profilePhoto be an image or a link to the image?
    //var profilePhoto: URL? // or UIImage
    var profilePhoto: UIImage?
    
    // Only needed for the main user
    var groups = [Group]()
    
    // Default initializer, the minimum data required to initialize one
    init(uid: String, handle: String) {
        self.uid = uid
        self.handle = handle
    }
    
    // Used in AddUser / User Search, where the user will only be initialized once the profile photo is loaded
    // No real need to use convenience. More to show that this is not the primary initializer
    convenience init(uid: String, handle: String, profilePhoto: UIImage) {
        self.init(uid: uid, handle: handle)
        
        self.profilePhoto = profilePhoto
    }
    
    // Called whenever a post has been added to a group
    // Move the updated group to the front of the array
    // Also returns the index so ... the GroupsVC knows which index to reference?
    func groupUpdated(group: Group) -> Int {
        var index = -1
        
        for i in 0...self.groups.count {
            if self.groups[i].uid == group.uid {
                index = i
            }
        }
        
        // If the group could be found, and is not already at the top(index of 0)
        if index > 1 {
            // Remove it at whatever index it's at
            groups.remove(at: index)
            
            // And add it to the front(shifts all other elements down an index)
            groups.insert(group, at: 0)
            
        } else { // Group argument was not in the groups array
            print("Group with name \(group.name) could not be found in mainUser.groups!")
        }
        
        return index
    }
    
    func convertToDict() -> [String : Any] {
        var dict = [String : Any]()
        
        return dict
    }
}
