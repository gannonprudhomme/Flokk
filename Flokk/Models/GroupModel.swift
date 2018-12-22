//
//  GroupModel.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 12/17/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import Foundation

class GroupModel {
    var uid: String
    var name: String
    var icon: UIImage? // Need to ensure this is only loaded in once
    
    init(uid: String, name: String) {
        self.uid = uid
        self.name = name
        
        icon = nil
    }
    
    // Set icon once it's loaded in?
    // Call it from whatever handles the icons - GroupModelController?f
    
}
