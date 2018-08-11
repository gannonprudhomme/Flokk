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
    
    var members: [User]?
    var posts: [Post]? // Does it matter when this is initialized?
    
    // Is this needed?
    var numNewPosts: Int = 0
    
    var newestPostTime: Date!
    
    init(uid: String, name: String) {
        self.uid = uid
        self.name = name
        
        // Set the default icon before the original is loaded
        setIcon(icon: UIImage(named: "GroupIcon")!)
        
        posts = [Post]()
        members = [User]()
    }
    
    func addPost(post: Post) {
        // Set the newest post time
        
        // Add it to the posts array
    }
    
    // or reorderPosts()
    func sortPosts() {
        
    }
    
    // Attempt to load the group Icon
    // If it's already loaded, return immediately
    // Otherwise, load it in from Firebase
    func requestGroupIcon(completion: @escaping (URL) -> Void) {
        
    }
    
    func setIcon(icon: UIImage) {
        self.icon = icon
    }
    
    func getIcon() -> UIImage? {
        return icon
    }
}
