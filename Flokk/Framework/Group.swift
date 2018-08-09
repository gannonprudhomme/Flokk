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
    
    init(uid: String, name: String) {
        self.uid = uid
        self.name = name
        
        // Set the default icon before the original is loaded
        setIcon(icon: UIImage(named: "HOME ICON")!)
        
        posts = [Post]()
        members = [User]()
    }
    
    func addPost(post: Post) {
        
    }
    
    // or reorderPosts()
    func sortPosts() {
        
    }
    
    func setIcon(icon: UIImage) {
        self.icon = icon
    }
    
    func getIcon() -> UIImage? {
        return icon
    }
}
