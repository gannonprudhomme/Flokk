//
//  Post.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 7/28/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import Foundation

// Tuple for the pixel dimensions of the video
typealias Dimensions = (width: Int?, height: Int?)

// Represents a user's post within a Feed
class Post {
    var uid: String!
    
    // Private and have a getter?
    // Set only after the video has been loaded
    var fileURL: URL?
    
    // Private and have a getter?
    var timestamp: Double
    
    // Width and height of the video, in pixels
    // Can this be retrieved from the URL?
    var dimensions: Dimensions?
    
    var loaded = false
    
    init(dimensions: Dimensions, timestamp: Double!) {
        self.timestamp = timestamp
        
        self.dimensions = dimensions
    }
    
    init(url: URL, dimensions: Dimensions, timestamp: Double) {
        self.fileURL = url
        self.timestamp = timestamp
        self.dimensions = dimensions
    }
}
