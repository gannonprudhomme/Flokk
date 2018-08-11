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
    var icon: UIImage? // Once it's loaded in, set it. Should it be a URL
    
    var members: [User]?
    var posts: [Post]? // Does it matter when this is initialized?
    
    // Is this needed?
    var numNewPosts: Int = 0
    
    var newestPostTime: Date!
    
    init(uid: String, name: String) {
        self.uid = uid
        self.name = name
        
        // Set the default icon before the original is loaded
        
        posts = [Post]()
        members = [User]()
    }
    
    func addPost(post: Post) {
        // Set the newest post time
        
        // Add it to the posts array
    }
    
    // or reorderPosts()
    // We basically manually sort every time, so no need
    func sortPosts() {
        
    }
    
    // TODO: Should this be done in here?
    // Attempt to load the group Icon
    // If it's already loaded, return immediately
    // Otherwise, load it in from Firebase
    func requestGroupIcon(completion: @escaping (UIImage?) -> Void) {
        //if icon == nil {
            // Load it from firebase
            
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
        //}
    }
    
    func setIcon(icon: UIImage) {
        self.icon = icon
    }
    
    func getIcon() -> UIImage? {
        return icon
    }
}
