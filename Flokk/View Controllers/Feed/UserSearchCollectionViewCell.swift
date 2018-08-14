//
//  UserSearchCollectionViewCell.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 8/14/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import UIKit

class UserSearchCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var profilePhotoView: UIImageView!
    
    var user: User!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profilePhotoView?.layer.cornerRadius = profilePhotoView.frame.size.width / 2
        profilePhotoView.clipsToBounds = true
        
        if let user = user {
            profilePhotoView.image = user.profilePhoto
        }
    }
    
    
}
