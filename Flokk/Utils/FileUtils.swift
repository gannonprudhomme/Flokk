//
//  FileUtils.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 8/17/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import Foundation
import UIKit

// Helper class that would take care of saving and loading data to the disk
// Handles JSON for group and feed data, as well as saving group icons and post videos
class FileUtils {
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
        
    }
    
    // Check if the post video is loaded
    static func isPostLoaded(post: Post) {
        
    }
}
