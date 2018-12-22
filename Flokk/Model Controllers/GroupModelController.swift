//
//  GroupModelController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 12/21/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import Foundation
import Promises

// Contains a global instance of all of the groups within the app
// Probably store them in a hashmap/hastable, with their uid as they key
// Also provide functions to retrieve group data from the database
class GroupModelController {
    var groups: [String : GroupModel]! = nil // Ideally this is a hashmap
    
    
    // Load the group and
    func loadGroup(uid: String) -> Promise<String> {
        // Immediately register this group in the map so we don't double load
        return Promise<String> { fulfill, reject in
            
            
            
        }
    }
}
