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
        let url = getDocumentsDirectory().appendingPathComponent(file)
        
        do {
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            
            if let dictionary = json as? [String : Any] {
                print("Sucessfully loaded \(url.lastPathComponent)")
                
                return dictionary
            } else {
                // Something went wrong, return nil, forcing it to load in the data directly from the database
                // Basically handles 
                return nil
            }
        } catch {
            print("Could not load \(url.lastPathComponent)")
            //print(error)
            
            // File doesn't exist, load it in from the database
            return nil
        }
    }
    
    static func saveToJSON(dict: [String : Any], toPath path: String) {
        // Create the directory for the posts to be stored
        let fileManager = FileManager.default
        
        let finalURL = getDocumentsDirectory().appendingPathComponent(path)
        do {
            try fileManager.createDirectory(at: finalURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
            
            let json = JSON(dict)
            let str = json.description
            try str.write(to: finalURL, atomically: true, encoding: .utf8)
            
            print("Successfully saved \(finalURL.lastPathComponent)")
        } catch let error {
            print("Unsuccessfully saved \(finalURL.lastPathComponent)")
            print(error)
        }
        
    }
    
    static func doesFileExist(atPath: String) -> Bool{
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent(atPath) {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                //print("FILE AVAILABLE")
                return true
            } else {
                //print("FILE NOT AVAILABLE   \(filePath)")
                return false
            }
        } else {
            //print("FILE PATH NOT AVAILABLE")
            return false
        }
    }
    
    static func loadImage(path: String) -> UIImage? {
        let url = getDocumentsDirectory().appendingPathComponent(path)
        
        do {
            let data = try Data(contentsOf: url)
            
            if let image = UIImage(data: data) {
                return image
            }
        } catch let error {
            print(error)
            return nil
        }
        
        return nil
    }
    
    // Save an image to the local disk
    static func saveImage(image: UIImage, toPath path: String) {
        if let data = UIImageJPEGRepresentation(image, 1) {
            let fileURL = getDocumentsDirectory().appendingPathComponent(path)
            
            do {
                try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
                
                try data.write(to: fileURL)
                
                print("\n\(path) saved successfully!\n")
            } catch let error {
                print(error)
                return
            }
        }
    }
    
    // Save the group icon currently saved in group.icon to the disk
    static func saveGroupIcon(group: Group) {
        saveImage(image: group.icon!, toPath: "groups/\(group.uid).jpg")
    }
    
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

// JSON Manipulation functions for app framework
extension FileUtils {
    // Save the group to the user's json file and make one for it
    static func saveGroup(_ group: Group) {
        
    }
    
    static func deleteGroup(_ group: Group) {
        
    }
}
