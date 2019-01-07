//
//  PostModel.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 12/17/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import Foundation

// The dimensions of this file, used for pre-allocating
// Enough space for this post in the Feed View
struct Dimensions {
    var width: Int
    var height: Int
    
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }
}

// A post in Flokk is represented as a video, and also contains an according preview image
// that is displayed before the video is played, which is usually the first frame of the video
class PostModel {
    // Values
    var uid: String // The Unique ID for this post
    var groupUID: String // The uid for the Group this post was uploaded in, how will/when will this be used?
    var timestamp: Double // The date in milliseconds when the post was uploaded
    var authorUID: String? // The uid of the user who uploaded this post
    
    var filePath: String? // Local (temporary?) file path to the location of the downloaded video
    
    // Width and height of the 
    var dimensions: Dimensions?
    
    // var previewImage: UIImage? // The image to be displayed before a video is played in a Feed
    
    init(uid: String, groupUID: String, timestamp: Double) {
        self.uid = uid
        self.groupUID = groupUID
        self.timestamp = timestamp
    }
    
    // Getters and Setters?
}
