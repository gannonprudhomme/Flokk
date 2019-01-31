//
//  LocalFileController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 12/21/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import Foundation
import UIKit

enum PATH: String {
    case GROUPS = "groups/"
    case USERS = "users/"
    case ICONS = "/icons/"
}

// Again not really a Controller, as it doesn't communicate with the view
// Change this into a Util?
// Loads in/saves Models from/to their respective files
class LocalFileController {
    static func doesGroupFileExist(uid: String) -> Bool {
        return false
    }
    
    static func loadDictFromFile(_ path: String) -> [String : Any]? {
        return nil
    }
    
    // Returns a dictionary of all of the group data at the given path
    static func loadGroupDictFromFile(uid: String) -> [String : Any]? {
        return loadDictFromFile(PATH.GROUPS.rawValue + uid)
    }
    
    static func loadImage(path: String) -> UIImage? {
        return nil
    }
}
