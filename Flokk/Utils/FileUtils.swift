//
//  FileUtils.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 8/17/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

// Helper class that would take care of saving and loading data to the disk
// Handles JSON for group and feed data, as well as saving group icons and post videos
class FileUtils {
    static func createDirectory(path: String) -> URL? {
        // Create the directory for the posts to be stored
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let outputURL = documentDirectory.appendingPathComponent(path)
        
        do {
            try fileManager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
            
            // If the creation was successful, return the url
            return outputURL
        } catch let error {
            print(error)
            
            return nil
        }
    }
    
    static func loadJSON(file: URL) -> NSDictionary {
        let dict = NSDictionary()
        
        return dict
    }
    
    static func saveToJSON(dictionary: NSDictionary) {
        
    }
    
    // If this returns nil, we have to download the group icon from Firebase
    static func loadGroupIcon(group: Group) -> UIImage? {
        let image: UIImage
        
        
        return nil
    }
    
    // Save the group icon currently saved in group.icon to the disk
    static func saveGroupIcon(group: Group) {
        let icon = group.icon
        let data = icon?.convertJpegToData()
        
        let outputURL = createDirectory(path: "groups/\(group.uid)")
        let url = outputURL?.appendingPathComponent("icon").appendingPathExtension("jpg")
        
        FileManager.default.createFile(atPath: (url?.path)!, contents: data, attributes: nil)
    }
    
    // Check if the post video is loaded
    static func isPostLoaded(group: Group, post: Post) -> Bool {
        let outputURL = FileUtils.createDirectory(path: "groups/\(group.uid)/posts")
        let url = outputURL?.appendingPathComponent("\(post.uid).mp4")
        
        // Attempt to initialize an AVAsset to see if the file exists
        if let asset = AVAsset(url: url!) as? AVAsset {
            return true
        } else {
            return false
        }
    }
}
