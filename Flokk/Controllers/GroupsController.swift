//
//  GroupsController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 12/21/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import Foundation
import Promises

// Not a typical Controller as it doesn't communicate with/control any View directly.
//  However, other controllers that communicate with Views will call functions from this anytime they need access to a group
// Contains a global instance of all of the groups within the app
// What the view controllers and such interface with to access/modify Group data
class GroupsController {
    // Any group that needs more than a UID and a name(ie storing a group icon, posts data, etc) needs to be in here
    var groupsMap = [String : GroupModel]() // Ideally this is a hashmap
    
    // var feedDelegage: FeedDelegate! // Would update the feed with a new post(uid) if the post data hadn't loaded in time before entering the feed
    
    // At a point in time, we can't always assume that a group is loaded
    // Called (when?)
    func getGroup(uid: String, name: String) -> Promise<GroupModel> {
        return Promise { fulfill, reject in
            if self.mapContainsGroup(uid: uid) { // If the Group is already loaded in
                fulfill(self.groupsMap[uid]!)
                
            } else {
                // Add the group to the map
                self.groupsMap[uid] = GroupModel(uid: uid, name: name)
                
                self.loadGroup(uid: uid).then({ groupModel in
                    fulfill(groupModel)
                }).catch({error in
                    reject(error) // This might be done automatically
                })
            }
        }
    }
    
    // Dunno if I really like this in here
    func loadGroup(uid: String) -> Promise<GroupModel> {
        // Immediately register this group in the map so we don't double load
        return Promise { fulfill, reject in
            var group = GroupModel(uid: uid) // Create the GroupModel object
            
            // If there is a local file
            if LocalFileController.doesGroupFileExist(uid: uid) {
                // I should probably do the below stuff
                // Load the local file
                    // processGroupData(value)
                
                // Load in the posts data
                    // Manually set the post data at groups[uid].postsData, compare it to the old data
                
                // Load in the members data
                    // Manually set the post data at groups[uid].members, compare it to the old data
                
                fulfill(GroupModel(uid: "", name: ""))
                
            } else { // If there isn't a local file
                // Didn't load the group from a local file, load it in from the database and (maybe) save it to a file
                group.loadGroupFromDatabase(uid: uid).then({ group in
                    fulfill(group) // Return the loaded group
                    
                    // Save it to a file?
                    
                }).catch({ error in
                    reject(error)
                })
            }
        }
    }
}

// Map helper functions
extension GroupsController {
    // Returns true if the uid is in groupsMap
    func mapContainsGroup(uid: String) -> Bool {
        return groupsMap.contains(where: { key, value in
            return key == uid
        })
    }
}
