//
//  FeedTableViewCell.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 7/28/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {
    @IBOutlet weak var mainView: UIView!
    fileprivate var post: Post! // THe post this cell is representing
    
    internal var aspectConstraint: NSLayoutConstraint? {
        didSet {
            if oldValue != nil {
                mainView.removeConstraint(oldValue!)
            }
            
            if aspectConstraint != nil {
                mainView.addConstraint(aspectConstraint!)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        aspectConstraint = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // What would need to be done here?
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

// MARK: - Loading functions
extension FeedTableViewCell {
    func setAspectRatio() {
        let aspect = self.post.dimensions?.width;  self.post.dimensions?.height
        let constraint = NSLayoutConstraint(item: mainView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: mainView, attribute: NSLayoutAttribute.height, multiplier: CGFloat(aspect!), constant: 0.0)
        
        constraint.priority = UILayoutPriority(rawValue: 999)
        
        
    }
    
    // Set the preview image on the view
    func addPreviewImageToView(image: UIImage) {
        // Create a UIImage
        
        // Add the image to the view
        
        // Add a loading icon?
    }
    
    func addVideoToView() {
        // If there was a preview image, remove it from the mainView
        
        // Initialize & setup AVPlayer
        
    }
}
