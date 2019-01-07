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

// Errors pertaining to GroupModel loading
enum GroupLoadingError: Error {
    case notFoundInDatabase
    case databaseError
    case invalidFileFormatting
    case processDataError(String)
}

// Not a normal kind of controller, as it doesn't interact with the View whatsoever
// Provides extra functions for the GroupModel class that would clug up the GroupModel file
// Adds various data loading functions from the database
extension GroupModel {
    // Load the group data from the database
    func loadGroupFromDatabase() -> Promise<GroupModel> {
        return Promise{ fulfill, reject in
            // Retrive the groups data for this group from the databse
            database.child("groups").child(self.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let value = snapshot.value as? [String : Any] else {
                    // If the value is loaded in wrong, throw a database error
                    reject(GroupLoadingError.databaseError)
                    return
                }
                
                // Attempt to process the group data
                do {
                    try self.processGroupData(value)
                } catch GroupLoadingError.processDataError(let errorMessage) { // Handle the error if the group data is lacking necessary data
                    print(errorMessage)
                } catch {
                    print("some other error")
                }
                
                // Anything else?
            })
        }
    }
    
    //Can we assume the local file exists at this point
    func loadGroupFromFile(uid: String) -> Promise<GroupModel> {
        return Promise { fulfill, reject in
            // Load the local file
                // processGroupData(value)
            
                // Load in the posts data
                    // Manually set the post data and compare it to the old data
                        // Notify the relevant FeedController that there were new posts
            
                // Load in the members data
                    // Manually set the post data and compare it to the old data
                         // Notify the relevant GroupSettingsController that there were new posts
        }
    }
    
    // Load a dict of the group's members containing their uid and name
    func loadGroupMembers() -> Promise<[String : String]> {
        return Promise{ fulfill, reject in
            let ret = [String : String]()
            // First check if the Group is loaded & exists in the database
            
            // Download it from the datbase
                // Return it
                fulfill(ret)
        }
    }
    
    // Load the group's icon from Storage - Should this be in here?
    func loadGroupIcon() -> Promise<UIImage?> {
        return Promise{ fulfill, reject in
            // First check if the Group is loaded & exists in the database, or is this not necessary'
            
            fulfill(nil)
        }
    }
    
    // Process the Group data from JSON/dictionary format and load it into this GroupModel instance
    // Called from either the local file or the database group loading
    func processGroupData(_ value: [String : Any]) throws {
        // Need to have checks if the group data isn't formatted properly, or data is missing(when it shouldn't be missing)
        
        // Attempt to load in the Group's name
        guard let name = value["name"] as? String else {
            // throw an errorhttps://discord.gg/fcjGqB
            throw(GroupLoadingError.processDataError("Couldn't load name"))
        }
        self.name = name // Set the name for this group
        
        // Attempt to load in the creator's UID
        guard let creatorUID = value["creator"] as? String else {
            // throw an error
            throw(GroupLoadingError.processDataError("Couldn't load creatorUID"))
        }
        self.creatorUID = creatorUID
        
        // Attempt to load in the creation date
        guard let creationDate = value["creationDate"] as? Double else {
            // Throw an error
            throw(GroupLoadingError.processDataError("Couldn't load creationDate"))
        }
        self.creationDate = creationDate
        
        // Check if there is members data - When will there not be?
        // Will(should) always have at least 1 member(the creator)
        guard let members = value["members"] as? [String : String] else {
            throw(GroupLoadingError.processDataError("Couldn't load members"))
        }
        
        // Format and load the members
        for (uid, name) in members { // Iterate through all of the members
            // And add them to the members list
            self.members.append(uid)
            
            //TODO: Add them to UsersContainer?
        }
        
        // Check if there is posts data
        // Isn't a guard, as there's a chance that a post hasn't been uploaded to a Group
        if let posts = value["posts"] as? [String: [String : Any]] {
            // Format and load the posts in here
            for (uid, data) in posts {
                // Handle the posts, create them and add them to the lists of posts?
                
            }
        }
    }
}

extension GroupModel {
    // Upload this (initialized) group to the database
    // Should only be called from CreateGroupViewController(or whatever it's called)
    func uploadGroupToDatabase() {
        let groupRef = database.child("groups").child(uid)
        
        // Upload the group name
        groupRef.child("name").setValue(name)
        
        // Upload the creator uid
        groupRef.child("creator").setValue(creatorUID)
        
        // Upload and set the creation date to right now
        groupRef.child("creationDate").setValue(Date.timeIntervalSinceReferenceDate)
        
        // Add the main user(creator) as member in the members array
        // groupRef.child("members")
        
        // Upload the group icon to storage
    }
}

extension GroupModel {
    // Add a post to this group
    func uploadPost(post: PostModel) {
        // How should I handle uploading the post to Storage?
    }
}
