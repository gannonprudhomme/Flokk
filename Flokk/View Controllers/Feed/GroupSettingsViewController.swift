//
//  GroupSettingsViewController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 8/13/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import UIKit

class GroupSettingsViewController: UIViewController {
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupIconView: UIImageView! // This should be a button
    @IBOutlet weak var collectionView: UICollectionView!
    
    var group: Group!
    var leaveGroupDelegate: LeaveGroupDelegate! // 
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Crop the group icon to a circle
        groupIconView?.layer.cornerRadius = groupIconView.frame.size.width / 2
        groupIconView.clipsToBounds = true
        
        groupNameLabel.text = group.name
        groupIconView.image = group.getIcon()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func leaveButtonPressed(_ sender: Any) {
        // Create an alert
        let alert = UIAlertController(title: "Leave Group", message: "Are you sure you want to leave \(group.name)", preferredStyle: .alert)
        
        let confirmActionButton = UIAlertAction(title: "Confirm", style: .default, handler: { (_) in
            // Remove the user from the group in the database
            self.leaveGroupDelegate.leaveGroup(group: self.group)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        alert.addAction(confirmActionButton)
        
        present(alert, animated: true, completion: nil)
    }
}

extension GroupSettingsViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "default", for: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
}
