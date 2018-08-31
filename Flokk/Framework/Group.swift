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
    
    var members: [User]
    
    // After initial post initialization
    var posts: [Post] // Does it matter when this is initialized?
    
    // Is this needed?
    var numNewPosts: Int = 0
    
    var newestPostTime: Double!
    
    // Assigned when we segue into a group's Feed in Groups.prepareForSegue
    // Unassigned in Feed.viewDidDisappear
    // Instance variable of the group so GroupsVC.loadGroupData has access to the Feed's tableView
    var feedDelegate: NewPostDelegate!
    
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
    }
    
    // TODO: Should this be done in here?
    // Attempt to load the group Icon. If it's already loaded, return immediately
    // Otherwise, load it in from Firebase
    func requestGroupIcon(completion: @escaping (UIImage?) -> Void) {
        // Check if the icon is stored locally
        if let image = FileUtils.loadGroupIcon(group: self) {
            icon = image
            
        // If it's not, download it from Firebase
        } else {
            storage.child("groups").child(uid).child("icon.jpg").getData(maxSize: MAX_PROFILE_PHOTO_SIZE, completion: { (data, error) in
                if error == nil {
                    let icon = UIImage(data: data!)
                    
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
