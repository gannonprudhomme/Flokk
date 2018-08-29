//
//  Networking.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 8/28/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import Foundation

// Functions for processing the Group and Feed data within Flokk
// Includes:
// - Loading the initial data, and manipulating the table cells for the according groups
//   - this includes handling the local data, then loading in the
// - adding observers for new groups/posts and all of the functions incorborated with them
extension GroupsViewController {
    // Load the data for the group
    func loadGroupData(index: Int) {
        var group = mainUser.groups[index]
        
        // If there is a local file
        if let value = FileUtils.loadJSON(file: "groups/\(group.uid)") {
            // Read from the local file
            processGroupData(group: &group, value: value)
            
            let groupRef = database.child("groups").child(group.uid)
            
            // Download and compare the database data
            // If there are new posts/members, insert them
            // Query by the most recent timestamp to only get new posts
            // Add the new posts and download the video for them
            groupRef.child("posts").queryOrdered(byChild: "timestamp").queryStarting(atValue: group.newestPostTime).observeSingleEvent(of: .value, with: { (snapshot) in
                print(value)
                if let value = snapshot.value as? [String : Any] {
                    // Iterate through all of the post IDs
                    // These should be completely new posts
                    for postID in value.keys {
                        let data = value[postID] as! [String : Any]
                        
                        let timestamp = data["timestamp"] as! Double
                        //let poster = value[postID]!["poster"] as! String // UID of the poster, unused for now
                        let width = data["width"] as! Int
                        let height = data["height"] as! Int
                        
                        let post = Post(uid: postID, timestamp: timestamp)
                        post.setDimensions(width: width, height: height)
                        
                        // Simplt add it to the posts array
                        // We don't call group.addPost(...) b/c that is for new posts, not existing oness
                        group.posts.append(post)
                    }
                }
            })
            
            // Download the member data and compare, checking if we have a new user or not
            groupRef.child("members").observeSingleEvent(of: .value, with: { (snapshot) in
                if let value = snapshot.value as? [String : Any] {
                    //let oldMembers = self.group.members
                    let newMemberUIDs = value.keys as! [String]
                    
                    // Remove the matches between the new and old members
                    
                }
            })
            
            // Save the new data locally
            
        // If there is no local file
        } else {
            // Download the database data and load it directly in
            database.child("groups").child(group.uid).child("posts").observeSingleEvent(of: .value, with: { (snapshot) in
                if let value = snapshot.value as? [String : [String : Any]] {
                    for postID in value.keys {
                        let timestamp = value[postID]!["timestamp"] as! Double
                        //let poster = value[postID]!["poster"] as! String // UID of the poster, unused for now
                        let width = value[postID]!["width"] as! Int
                        let height = value[postID]!["height"] as! Int
                        
                        let post = Post(uid: postID, timestamp: timestamp)
                        post.setDimensions(width: width, height: height)
                        
                        // Simplt add it to the posts array
                        // We don't call group.addPost(...) b/c that is for new posts, not existing oness
                        //group.posts.append(post)
                    }
                    
                    // Save the post data after all of the posts are loaded
                   // FileUtils.saveToJSON(dict: group.convertToDict(), toPath: "groups/\(self.group.uid).json")
                    
                    // After loading in all of the posts, sort them
                    //self.sortPosts()
                    
                    // Set how many posts to load, depending on how many we have
                    //self.currentPostCount = self.group.posts.count
                    
                    // Done loading posts data, call completion with true, meaning posts have actually been loaded
                    //completion(true)
                } else {
                    //completion(false)
                }
            })
        }
        
        
    // If the group data is loaded, we have already gone through this process
        // Do nothing
        // What about checking for changes? There could've been a post update when we weren't in the group
    }
    
    private func processGroupData(group: inout Group, value: [String : Any]) {
        let members = value["members"] as! [String : String]
        let creatorUID = value["creator"] as! String
        
        group.creatorUID = creatorUID
        
        // Iterate over the members dictionary and add them to the Group's member array
        // Used in Group Settings to show who is in the group
        for uid in members.keys {
            let handle = members[uid]
            
            group.members.append(User(uid: uid, handle: handle!))
        }
        
        // Load the posts
        if let posts = value["posts"] as? [String : [String : Any]] {
            for postID in posts.keys {
                let timestamp = posts[postID]!["timestamp"] as! Double
                //let poster = value[postID]!["poster"] as! String // UID of the poster, unused for now
                let width = posts[postID]!["width"] as! Int
                let height = posts[postID]!["height"] as! Int
                
                let post = Post(uid: postID, timestamp: timestamp)
                post.setDimensions(width: width, height: height)
                
                // Simplt add it to the posts array
                // We don't call group.addPost(...) b/c that is for new posts, not existing oness
                group.posts.append(post)
            }
            
            // After loading in all of the posts, sort them
            group.posts.sort(by: { $0.timestamp > $1.timestamp})
            
            // Set the newest post time as the top most post
            if group.posts.count > 0 {
                group.newestPostTime = group.posts[0].timestamp
            } else { // If there are no posts
                // TOOD: Set the timestamp to the group's creation date
                //group.newestPostTime = group.creatio
            }
            
            // If the feed's instance exists, update the tableView
            if let _ = group.feedDelegate {
                // Update the feed
            }
            
            // Done loading posts data, call completion with true, meaning posts have actually been loaded
            //completion(true)
        }
    }
}

extension GroupsViewController {
    /*
    fileprivate func removeMatches<User>(_ first: [User], _ second: [User]) -> [User] {
        return first.filter({ (user) in
            second.contains(where: { (user2) in
                return user2.uid == user.uid
            })
        })
    } */
}
