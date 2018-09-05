//
//  Group.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 8/8/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import Foundation
import UIKit

// Represents all groups in Flokk
class Group: CustomStringConvertible {
    var uid: String
    var name: String
    var icon: UIImage? // Once it's loaded in, set it
    var creatorUID: String?
    var creationDate: Double?
    
    var members: [User]
    
    // After initial post initialization
    var posts: [Post] // Does it matter when this is initialized?
    
    // Is this needed?
    var numNewPosts: Int = 0
    
    var newestPostTime: Double = 0
    
    // Assigned when we segue into a group's Feed in Groups.prepareForSegue
    // Unassigned in Feed.viewDidDisappear
    // Instance variable of the group so GroupsVC.loadGroupData has access to the Feed's tableView
    var feedDelegate: NewPostDelegate!
    var sortGroupsDelegate: SortGroupsDelegate!
    
    init(uid: String, name: String) {
        self.uid = uid
        self.name = name
        
        // Set the default icon before the original is loaded
        
        posts = [Post]()
        members = [User]()
    }
    
    func addPost(post: Post) {
        // Set the newest post time
        newestPostTime = post.timestamp
        
        // Add it to the top posts array
        posts.insert(post, at: 0)
        
        // Move the GroupsVC tableViewCell to the top
        sortGroupsDelegate.groupUpdated(group: self)
    }
    
    // Attempt to load the group Icon. If it's already loaded, return immediately
    // Otherwise, load it in from Firebase
    func requestGroupIcon(completion: @escaping (UIImage?) -> Void) {
        // Check if the icon is stored locally
        if let image = FileUtils.loadImage(path: "groups/\(uid)/icon.jpg") {
            icon = image
            
        // If it's not, download it from Firebase
        } else {
            storage.child("groups").child(uid).child("icon.jpg").getData(maxSize: MAX_PROFILE_PHOTO_SIZE, completion: { (data, error) in
                if error == nil {
                    let icon = UIImage(data: data!)
                    
                    self.icon = icon
                    
                    // Save the group icon locally so we don't have to download it again
                    //FileUtils.saveGroupIcon(group: self)
                    
                    completion(icon)
                } else {
                    print(error?.localizedDescription)
                    
                    completion(nil)
                    return
                }
            })
        }
    }
    
    func setIcon(icon: UIImage) {
        self.icon = icon
    }
    
    // whats the point of having both this and requestGroupIcon
    func getIcon() -> UIImage? {
        return icon
    }
    
    // Sort the posts in ascending order(largest/most-recent timestamp first)
    // Should only be called once, after the posts are first loaded, any additional posts are brand new
    func sortPosts() {
        posts.sort(by: { $0.timestamp > $1.timestamp})
    }
    
    // Converts this Group object to a dictionary for saving the data to JSON(locally)
    // Replicates the structure of the database
    // Need to be careful when I call this. If the group data isn't fully loaded, the file will be missing things
    func convertToDict() -> [String : Any] {
        var data = [String : Any]()
        
        data["creator"] = creatorUID ?? "nil"
        data["name"] = name
        data["creationDate"] = creationDate
        
        // Iterate through the members and store their data
        var membersData = [String : Any]()
        for member in self.members {
            membersData[member.uid] = member.handle
        }
        
        data["members"] = membersData
        
        // Iterate through the posts and store its data
        var postsData = [String : Any]()
        for post in self.posts {
            postsData[post.uid] = post.convertToDict()
        }
        
        data["posts"] = postsData
        
        // Fill the dictionary with the post data
        return data
    }
    
    public var description: String {
        var desc = ""
        
        desc += uid + "\n"
        desc += name + "\n"
        desc += "Posts: \n"
        
        for post in posts {
            desc += "\t \(post) \n"
        }
        
        desc += "Members: \n"
        for member in members {
            desc += "\t \(member.handle!) \n"
        }
        
        return desc
    }
}

// Data loading
extension Group {
    // Load all of the data in here so we can mutate the members asynchronously,
    // While still being able to sort the groups whenever we want
    func loadData() {
        // If there is a local file
        if let value = FileUtils.loadJSON(file: "groups/\(uid)/data.jsonadf") {
            // Read from the local file
            self.processGroupData(value: value)
            
            let groupRef = database.child("groups").child(uid)
            
            // Download and compare the database data
            // If there are new posts/members, insert them
            // Query by the most recent timestamp to only get new posts
            
            // Attempt to download any posts that have been uploaded after the most recent local post
            // Add 0.1 to newestPost timestamp, so we don't load/skip the most recent post
            groupRef.child("posts").queryOrdered(byChild: "timestamp").queryStarting(atValue: newestPostTime + 0.1).observeSingleEvent(of: .value, with: { (snapshot)  in
                if let groupValue = snapshot.value as? [String : Any] {
                    // Iterate through all of the post IDs
                    // These should be completely new posts
                    for postID in groupValue.keys {
                        if self.posts.contains(where: {$0.uid == postID}) { // Double check that we don't have this post loaded already
                            let data = groupValue[postID] as! [String : Any]
                            
                            let timestamp = data["timestamp"] as! Double
                            //let poster = value[postID]!["poster"] as! String // UID of the poster, unused for now
                            let width = data["width"] as! Int
                            let height = data["height"] as! Int
                            
                            let post = Post(uid: postID, timestamp: timestamp)
                            post.setDimensions(width: width, height: height)
                            
                            // Simplt add it to the posts array
                            self.addPost(post: post)
                            
                            print("\nAttempting to add new post to feed Delegate in \(self.name)\n")
                            if let _ = self.feedDelegate {
                                self.feedDelegate.newPost(post: post)
                            }
                        } else {
                            print("\nAttempted to load post \(postID) in group \(self.name)\n")
                        }
                    }
                    
                    // Sort the groups again, after all of the new post data is loaded
                    // This could be done a better way, perhaps only check if this group should be moved?
                    if let _ = self.sortGroupsDelegate {
                        self.sortGroupsDelegate.sortGroups()
                    }
                }
            })
            
            // Download the member data and compare, checking if we have a new user or not
            groupRef.child("members").observeSingleEvent(of: .value, with: { (snapshot) in
                if let membersValue = snapshot.value as? [String : Any] {
                    //print(membersValue)
                    var oldMembers = self.members // Copy of the members array that we can mutate
                    var newMemberUIDs = Array(membersValue.keys)
                    
                    // Remove the matches between the new and old members
                    for(i, oldUser) in oldMembers.enumerated().reversed(){
                        for (j, newUID) in newMemberUIDs.enumerated().reversed() {
                            if oldUser.uid == newUID {
                                oldMembers.remove(at: i)
                                newMemberUIDs.remove(at: j)
                            }
                        }
                    }
                    
                    // Add the new members to the group
                    for uid in newMemberUIDs {
                        // Load in the new user
                        let handle = membersValue[uid] as! String
                        
                        print("\nAdding new member \(handle) to group \(self.name)\n")
                        
                        // Add the user to the members array for this group
                        self.members.append(User(uid: uid, handle: handle))
                    }
                    
                    // TODO: Remove the members that aren't in the group anymore
                    for user in oldMembers {
                        for (j, member) in self.members.enumerated().reversed() {
                            if user.uid == member.uid {
                                self.members.remove(at: j)
                            }
                        }
                    }
                    
                    // Save the file, updating the member changes
                    FileUtils.saveToJSON(dict: self.convertToDict(), toPath: "groups/\(self.uid)/data.json")
                }
            })
        } else { // If there is no local file
            print("\nNo local file for group \(name)\n")
            // Download the database data and load it directly in
            database.child("groups").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                if let value = snapshot.value as? [String : Any] {
                    self.processGroupData(value: value)
                    
                    FileUtils.saveToJSON(dict: value, toPath: "groups/\(self.uid)/data.json")
                }
            })
        }
    }
    
    func processGroupData(value: [String : Any]) {
        let membersData = value["members"] as! [String : String]
        let creatorUID = value["creator"] as! String
        
        let creationDate = value["creationDate"] as! Double
        self.creationDate = creationDate
        
        self.creatorUID = creatorUID
        
        // Iterate over the members dictionary and add them to the Group's member array
        // Used in Group Settings to show who is in the group
        for uid in membersData.keys {
            let handle = membersData[uid]
            
            // Add the new user to the group's members array
            members.append(User(uid: uid, handle: handle!))
        }
        
        // Load the posts
        if let newPosts = value["posts"] as? [String : [String : Any]] {
            //print(posts)
            for postID in newPosts.keys {
                let timestamp = newPosts[postID]!["timestamp"] as! Double
                //let poster = value[postID]!["poster"] as! String // UID of the poster, unused for now
                let width = newPosts[postID]!["width"] as! Int
                let height = newPosts[postID]!["height"] as! Int
                
                let post = Post(uid: postID, timestamp: timestamp)
                post.setDimensions(width: width, height: height)
                
                // Simplt add it to the posts array
                posts.append(post)
                
                // If the feed is loaded in / is the current view
                if let _ = feedDelegate {
                    // Update the feed
                    feedDelegate.newPost(post: post)
                }
            }
            
            // After loading in all of the posts, sort them
            sortPosts()
            
            // Set the newest post time as the top most post
            if posts.count > 0 {
                self.newestPostTime = posts[0].timestamp
            } else { // If there are no posts
                // TOOD: Set the timestamp to the group's creation date
                self.newestPostTime = creationDate
            }
            
            // Sort the groups?
            if let _ = sortGroupsDelegate {
                sortGroupsDelegate.sortGroups()
            }
            
            // If the feed's instance exists, update the tableView with all of the new posts
            
        }
    }
}
