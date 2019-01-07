//
//  GroupModel.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 12/17/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import Foundation
import UIKit

class GroupModel {
    var uid: String // Unique Identifier for this Group, used to index these groups for quick access in GroupsController
    var name: String? // The actual name for this group
    var icon: UIImage? // Need to ensure this is only loaded in once
    
    var creatorUID: String? // The user who created this group's uid
    var creationDate: Double? // The date when this group was created
    var members: [String]? // Array of the members' uids
    var posts: [String]? // Array of post uid's within this group, sorted by timestamp greatest to least
    
    // Might be used when we don't know anything about the group, before we load it in
    init(uid: String) {
        self.uid = uid
    }
    
    init(uid: String, name: String) {
        self.uid = uid
        self.name = name
        
        icon = nil
    }
    
    func addMember(uid: String) { }
}
