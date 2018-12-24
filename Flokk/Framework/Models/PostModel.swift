//
//  PostModel.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 12/17/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import Foundation

// A post in Flokk is represented as a video, and also contains an according preview image
// that is displayed before the video is played, which is usually the first frame of the video
class PostModel {
    // Values
    var uid: String // The Unique ID for this post
    var authorUID: String? // The uid of the user who uploaded this post
    
    // Width and height of the 
    // var dimensions: Dimensions?
    
    // var previewImage: UIImage? // The image to be displayed before a video is played in a Feed
    
    init(uid: String) {
        self.uid = uid
        
    }
    
    // Getters and Setters?
}
