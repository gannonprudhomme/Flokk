//
//  GroupMemberCollectionViewCell.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 8/24/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import UIKit

class GroupMemberCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var user: User!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Crop the User's profile photo to a circle
        imageView.layer.cornerRadius = imageView.bounds.width / 2
        imageView.clipsToBounds = true
    }
    
    func initialize() {
        nameLabel.text = user.handle
        
        if user.profilePhoto == nil {
            
        } else {
            imageView.image = user.profilePhoto
        }
    }
}
