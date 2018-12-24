//
//  GroupModelController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 12/21/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import Foundation
import UIKit
import Promises

// Not a normal kind of controller, as it doesn't interact with the View whatsoever
// Provides extra functions for the GroupModel class that would clug up the GroupModel file
// Adds various data loading functions from the database
extension GroupModel {
    // var groups = [String : GroupModel]() // Ideally this is a hashmap
    
    // Load the group fromt the database
    func loadGroupFromDatabase(uid: String) -> Promise<GroupModel> {
        return Promise{ fulfill, reject in
            // Retrive the groups data for this group from the databse
            database.child("groups").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                if let value = snapshot.value as? [String : Any] {
                    self.processGroupData(value)
                    
                    // Save the group to the local json file
                    
                } else {
                    //reject("Group data loaded incorrectly")
                }
            })
        }
    }
    
    //Can we assume the local file exists at this point
    func loadGroupFromFile(uid: String) -> Promise<GroupModel> {
        return Promise { fulfill, reject in
            // Load the local file
                // processGroupData(value)
            
            // Load in the posts data
                // Manually set the post data at groups[uid].postsData and compare it to the old data
            
            // Load in the members data
                // Manually set the post data at groups[uid].members and compare it to the old data
        }
    }
    
    // Load a dict of the group's members containing their uid and name
    func loadGroupMembers(uid: String) -> Promise<[String : String]> {
        return Promise{ fulfill, reject in
            // First check if the Group is loaded & exists in the database
            let ret = [String : String]()
            
            fulfill(ret)
        }
    }
    
    // Load the group's icon from Storage
    func loadGroupIcon(uid: String) -> Promise<UIImage?> {
        return Promise{ fulfill, reject in
            // First check if the Group is loaded & exists in the database, or is this not necessary'
            
            fulfill(nil)
        }
    }
    
    // Process the Group data from JSON/dictionary format and load it into this GroupModel instance
    // Called from either the local file or the database group loading
    func processGroupData(_ value: [String : Any]) {
        // Need to have checks if the group data isn't formatted properly, or data is missing(when it shouldn't be missing)
        
    }
}
