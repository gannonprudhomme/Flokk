//
//  UserSearchCollectionViewCell.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 8/14/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import UIKit

// Represents the users that are selected to be invited, located above the search bar
class UserSearchCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var profilePhotoView: UIImageView!
    
    var user: User!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profilePhotoView?.layer.cornerRadius = profilePhotoView.frame.size.width / 2
        profilePhotoView.clipsToBounds = true
        //profilePhotoView.backgroundColor = UIColor.gray
        //profilePhotoView.image = UIImage(named: "Loading Image - Small")
        
        if let user = user {
            profilePhotoView.image = user.profilePhoto
        }
    }
    
    func initialize() {
        profilePhotoView.image = user.profilePhoto
    }
}
