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
import FirebaseAuth

enum UserLoadingError: Error {
    case processDataError(String)
}

// Provides extra functions for the UserModel class that would clug up the UserModel file
// Adds various data loading functions from the database
extension UserModel {
    // Load in the user from the database and set the according values
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
    
    // Load the user's profile photo from Storage
    func loadUserPhoto(uid: String) -> Promise<UIImage?> {
        return Promise { fulfill, reject in
            // Load in the photo from Storage, and return nil if it doesn't exist?
            
            fulfill(nil)
        }
    }
    
    // Need to process different user data, depending on if we're downloading main user data or not
    // When is this called? Checking a user's profile?
    func processUserData(_ value: [String : Any]) throws {
        // Attempt to load in the user's handle from the data
        guard let handle = value["handle"] as? String else {
            throw(UserLoadingError.processDataError("Coudln't load in handle"))
        }
        self.handle = handle
        
        // Attempt to load in the user's full name from the data
        guard let fullName = value["name"] as? String else {
            throw(UserLoadingError.processDataError("Coudln't load in fullName"))
        }
        self.fullName = fullName
        
        // Don't really care about the email, ignoring it for now
        
        // Attempt to load in the group IDs
        if let groups = value["groups"] as? [String : String] { // User won't always have groups, so no guard
            // Iterate through all of the groups
            for groupID in groups.keys {
                // Add it to the list of groups
                self.groups?.append(groupID)
            }
        }
    }
    
    // How should I format this? Probably shouldn't go in here
    func processMainUserData(_ value: [String : Any]) throws {
        let uid = Auth.auth().currentUser?.uid
        
        // Attempt to load in the user's handle from the data
        guard let handle = value["handle"] as? String else {
            throw(UserLoadingError.processDataError("Coudln't load in handle"))
        }
        self.handle = handle
        
        // Attempt to load in the user's full name from the data
        guard let fullName = value["name"] as? String else {
            throw(UserLoadingError.processDataError("Coudln't load in fullName"))
        }
        self.fullName = fullName
        
        // mainUser = UserModel(uid: uid!)
        // mainUser.fullName = fullName
        
        // Attempt to load in the group IDs
        if let groups = value["groups"] as? [String : String] { // User won't always have groups, so no guard
            // Load in each of the groupIDs
            for groupID in groups.keys {
                let groupName = groups[groupID]
                
                let group = GroupModel(uid: groupID, name: groupName!)
                // group.sortGroupsDelegate = self
                
                //let index = indexForUpdatedGroup(group: group)
                
                // mainUser.groups.insert(group, at: index)
                
                // group.loadData()
                
                // Attempt to download the group icon
                
            }
        }
    }
}
