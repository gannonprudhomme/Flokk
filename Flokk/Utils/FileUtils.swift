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
import SwiftyJSON

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
    
    // Load JSON file
    static func loadJSON(file: String) -> [String : Any]? {
        let url = getDocumentsDirectory().appendingPathComponent("users/mainUser.json")
        
        do {
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            
            if let dictionary = json as? [String : Any] {
                return dictionary
            } else {
                // Something went wrong, return nil, forcing it to load in the data directly from the database
                // Basically handles 
                return nil
            }
        } catch let error {
            print(error)
            
            // File doesn't exist, load it in from the database
            return nil
        }
    }
    
    static func saveToJSON(dict: [String : Any], toPath path: String) {
        // Create the directory for the posts to be stored
        //let fileManager = FileManager.default
        //let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        //let outputURL = documentDirectory.appendingPathComponent("users")
        
        do {
            //try fileManager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
            
            //var finalURL = outputURL.appendingPathComponent("mainUser").appendingPathExtension("json")
            var finalURL = getDocumentsDirectory().appendingPathComponent("users/mainUser.json")
            
            let json = JSON(dict)
            let str = json.description
            let data = str.data(using: .utf8)
            try str.write(to: finalURL, atomically: true, encoding: .utf8)
            
        } catch let error {
            print(error)
        }
        
    }
    
    // Attempt to load this groups icon from the local disk
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
    
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
