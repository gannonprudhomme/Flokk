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
class Group {
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
    // Attempt to load the group Icon
    // If it's already loaded, return immediately
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
                    return
                        
                        // Don't know if it matters if I return or do completion first
                        completion(nil)
                }
            })
        }
    }
    
    func setIcon(icon: UIImage) {
        self.icon = icon
    }
    
    func getIcon() -> UIImage? {
        return icon
    }
}
