//
//  UserSearchTableViewCell.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 8/14/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import UIKit

class UserSearchTableViewCell: UITableViewCell {
    @IBOutlet weak var profilePhotoView: UIImageView!
    @IBOutlet weak var handleLabel: UILabel!
    
    var user: User!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profilePhotoView?.layer.cornerRadius = profilePhotoView.frame.size.width / 2
        profilePhotoView.clipsToBounds = true

        if let user = user {
            initialize()
        } else {
            print("user not init")
        }
    }
    
    func initialize() {
        profilePhotoView.image = user.profilePhoto
        handleLabel.text = user.handle
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    
}
