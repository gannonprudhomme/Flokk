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
    var leaveGroupDelegate: LeaveGroupDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        groupNameLabel.text = group.name
        groupIconView.image = group.getIcon()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Leave the group
    @IBAction func leaveButtonPressed(_ sender: Any) {
        // Remove the user from the group in the database
        
        leaveGroupDelegate.leaveGroup(group: group)
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
