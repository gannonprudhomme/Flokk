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
    var users = [String : UserModel]()
    
    // Load the user's data from the database(all of it expect the profile photo)
    func loadUser(uid: String) -> Promise<UserModel> {
        return Promise { fulfill, reject in
            // Check if the user is loaded in locally? For now, just gonna load directly from the database
            self.loadUserFromDatabase(uid: uid).then({ user in
                fulfill(user)
            }).catch({error in
                reject(error)
            })
        }
    }
    
    // Load the user's profile photo from storage
    func loadUserPhoto(uid: String) -> Promise<UIImage?> {
        return Promise { fulfill, reject in
            fulfill(nil)
        }
    }
}

extension UserModelController {
    func loadUserFromDatabase(uid: String) -> Promise<UserModel> {
        return Promise { fulfill, reject in
            database.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                if let value = snapshot.value as? [String : Any] {
                    // Process user data
                    
                    // Save the current user data to a local file(only for main user?)
                    
                    // Load the user's profile photo?
                }
            })
        }
    }
}
