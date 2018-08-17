//
//  GroupsTableViewCell.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 8/8/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import UIKit

class GroupsTableViewCell: UITableViewCell {
    @IBOutlet weak var groupPhotoView: UIImageView! // Should be called icon
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var group: Group!
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func initialize() {
        nameLabel.text = group.name
        timeLabel.text = "Time"
        
        // Group the group icon to a circle
        groupPhotoView?.layer.cornerRadius = groupPhotoView.frame.size.width / 2
        groupPhotoView.clipsToBounds = true
        
        if let icon = group.getIcon() {
            groupPhotoView.image = icon
        } else {
            groupPhotoView.image = UIImage(named: "Loading Image")
        }
    }
}
