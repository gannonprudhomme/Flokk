//
//  GroupsTableViewCell.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 8/8/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import UIKit

class GroupsTableViewCell: UITableViewCell {
    @IBOutlet weak var groupPhotoView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var group: Group!
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func initialize() {
        
    }
}
