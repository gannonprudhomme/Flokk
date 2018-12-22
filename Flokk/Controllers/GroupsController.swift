//
//  GroupsController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 12/21/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import Foundation
import Promises

// Contains a global instance of all of the groups within the app
// What the view controllers and such interface with to access/modify Group data
class GroupsController {
    // Any group that needs more than a UID and a name(ie storing a group icon, posts data, etc) needs to be in here
    var groupsMap = [String : GroupModel]() // Ideally this is a hashmap
    
    var groupModelController: GroupModelController! // Is this the only instance I need of this?
    
    // var feedDelegage: FeedDelegate! // Would update the feed with a new post(uid) if the post data hadn't loaded in time before entering the feed
    
    init(groupMC: GroupModelController) {
        groupModelController = groupMC
    }

    // At a point in time, we can't assume that the group will be loaded
    // Called
    func getGroup(uid: String, name: String) -> Promise<GroupModel> {
        return Promise { fulfill, reject in
            if self.mapContainsGroup(uid: uid) { // If the Group is already loaded in
                fulfill(self.groupsMap[uid]!)
                
            } else {
                // Add the group to the map
                self.groupsMap[uid] = GroupModel(uid: uid, name: name)
                
                self.loadGroup(uid: uid).then({ groupModel in
                    fulfill(groupModel)
                })
            }
        }
    }
    
    // Load the group from the database
    func loadGroup(uid: String) -> Promise<GroupModel> {
        // Immediately register this group in the map so we don't double load
        return Promise { fulfill, reject in
            // var model = GroupModel(uid: uid, name: name) // Create the GroupModel object
            
            // If there is a local file
            if LocalFileController.doesGroupFileExist(uid: uid) {
                // Load the local file
                    // processGroupData(value)
                
                // Load in the posts data
                    // Manually set the post data at groups[uid].postsData, compare it to the old data
                
                // Load in the members data
                    // Manually set the post data at groups[uid].members, compare it to the old data
                
                fulfill(GroupModel(uid: "", name: ""))
                
            } else { // If there isn't a local file
                // Didn't load the group from a local file, load it in from the database and (maybe) save it to a file
                let groupData: [String : Any]! = nil
                
                self.groupModelController.loadGroupFromDatabase(uid: uid)
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
