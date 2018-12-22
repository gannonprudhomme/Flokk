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
    var uid: String
    var name: String?
    var icon: UIImage? // Need to ensure this is only loaded in once
    
    var members: [String]? // Array of the members' uids
    
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
