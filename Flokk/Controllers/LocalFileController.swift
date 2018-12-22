//
//  LocalFileController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 12/21/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import Foundation

enum PATH: String {
    case GROUPS = "groups/"
    case USERS = "users/"
    
}

// Loads in Models from their respective files
class LocalFileController {
    // 
    static func doesGroupFileExist(uid: String) -> Bool {
        return false
    }
    
    static func loadGroupDictFromFile(uid: String) -> [String : Any]? {
        
        
        return nil
    }
    
    static func loadImage(path: String) -> UIImage? {
        return nil
    }
}
