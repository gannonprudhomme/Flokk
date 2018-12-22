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

// Contains a global instance of all of the groups within the app
// Probably store them in a hashmap/hastable, with their uid as they key
// Also provide functions to retrieve group data from the database
class GroupModelController {
    var groups = [String : GroupModel]() // Ideally this is a hashmap
    
    // Add the group to the map
    func addGroup(group: GroupModel) {
        groups[group.uid] = group
    }
    
    // Load the following group data: creationDate, creator, name, icon?
    func loadGroup(uid: String, name: String) -> Promise<GroupModel> {
        // Immediately register this group in the map so we don't double load
        return Promise<GroupModel> { fulfill, reject in
            // var model = GroupModel(uid: uid, name: name) // Create the GroupModel object
            
            if groups.contains(where: { key, value in
                return key == uid}) {
                
                reject("Error: Wrong")
            } else {
                // Add the group to the hashtable
                groups[uid] = GroupModel(uid: uid, name: name)
            }
            
            // First check if we have this file stored locally
            if LocalFileController.doesGroupFileExist(uid: uid) {
                // If we do, load it in locally
                
            } else {
                // Didn't load the group from a local file, load it in from the database and (maybe) save it to a file
                let groupData: [String : Any]! = nil
                
                self.loadGroupFromDatabase(uid: uid)
            }
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
            // First check if the Group is loaded & exists in the database
            fulfill(nil)
        }
    }
}

extension GroupModelController {
    // Should this be in a separate file?
    func loadGroupFromDatabase(uid: String) -> Promise<GroupModel> {
        return Promise{ fulfill, reject in
            fulfill(GroupModel(uid: uid))
        }
    }
}
