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
    var uid: String
    var posterID: String?
    
    // Private and have a getter?
    // Set only after the video has been loaded
    var filePath: String?
    
    // Private and have a getter?
    var timestamp: Double
    
    // Width and height of the video, in pixels
    // Can this be retrieved from the URL?
    var dimensions: Dimensions?
    
    init(uid: String, timestamp: Double) {
        self.uid = uid
        self.timestamp = timestamp
    }
    
    // Used for testing
    init(dimensions: Dimensions, timestamp: Double) {
        self.timestamp = timestamp
        
        self.dimensions = dimensions
        self.uid = ""
    }
    
    // Used for testing
    init(path: String, dimensions: Dimensions, timestamp: Double) {
        self.filePath = path
        self.timestamp = timestamp
        self.dimensions = dimensions
        self.uid = ""
    }
    
    func setDimensions(width: Int, height: Int) {
        self.dimensions = Dimensions(width: width, height: height)
    }
    
    func getFileURL() -> URL? {
        if let _ = filePath {
            return FileUtils.getDocumentsDirectory().appendingPathComponent(filePath!)
        } else {
            return nil
        }
    }
    
    // Converts this post to a dictionary
    func convertToDict() -> [String : Any] {
        //var dict = [String : Any]()
        var data = [String : Any]()
        
        data["poster"] = posterID ?? "nil"
        data["timestamp"] = timestamp
        data["width"] = dimensions?.width ?? 0
        data["height"] = dimensions?.height ?? 0
        
        //dict[uid] = data
        
        return data
    }
    
    public var description: String {
        var desc = ""
        
        desc += "\(uid) \(DateUtils.getDate(timestamp: timestamp)) \n"
        
        return desc
    }
}
