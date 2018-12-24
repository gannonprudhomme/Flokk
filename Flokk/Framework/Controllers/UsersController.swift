//
//  UsersController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 12/24/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import Foundation
import Promises

// Contains a global instance of all of the users within the app
class UsersController {
    var usersDict: [String : UserModel] = [:] // Dictionary of the users currently loaded within the app
    
    // Load the user's data from the database(all of it expect the profile photo)
    func loadUser(uid: String) -> Promise<UserModel> {
        return Promise { fulfill, reject in
            if self.mapContainsUser(uid: uid) { // If the UserModel with that uid is stored in the Map
                fulfill(self.usersDict[uid]!) // Return the according UserModel
            } else { // User isn't loaded
                // Initialize it
                
                // Load it in (from the database?)
                
            }
        }
    }
}

extension UsersController {
    func mapContainsUser(uid: String) -> Bool {
        return usersDict.contains(where: { key, value in
            return key == uid
        })
    }
}
