//
//  GroupSettingsViewController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 8/13/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import UIKit

// User in AddUserVC for adding the user to the tableView
protocol AddUserDelegate {
    func addUsersToGroup(users: [User])
}

class GroupSettingsViewController: UIViewController, AddUserDelegate {
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupIconView: UIImageView! // This should be a button
    @IBOutlet weak var collectionView: UICollectionView!
    
    var group: Group!
    var leaveGroupDelegate: LeaveGroupDelegate! //
    
    let numberOfCellsPerRow: CGFloat = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Set the size of the cells in order to have two cells per row in the collectionView
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            let horizontalSpacing = flowLayout.scrollDirection == .vertical ? flowLayout.minimumInteritemSpacing : flowLayout.minimumLineSpacing
            let cellWidth = (view.frame.width - max(0, numberOfCellsPerRow - 1) * horizontalSpacing) / numberOfCellsPerRow
            flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        }
        
        // Load the member profile photos
        loadMembers()

        // Crop the group icon to a circle
        groupIconView?.layer.cornerRadius = groupIconView.frame.size.width / 2
        groupIconView.clipsToBounds = true
        
        groupNameLabel.text = group.name
        groupIconView.image = group.getIcon()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func leaveButtonPressed(_ sender: Any) {
        // Create an alert
        let alert = UIAlertController(title: "Leave Group", message: "Are you sure you want to leave \(group.name)", preferredStyle: .alert)
        
        let confirmActionButton = UIAlertAction(title: "Confirm", style: .default, handler: { (_) in
            // Remove the user from the group in the database
            self.leaveGroupDelegate.leaveGroup(group: self.group)
            
            // Segue back to the groups view
            self.performSegue(withIdentifier: "unwindToGroups", sender: nil)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        alert.addAction(confirmActionButton)
        
        present(alert, animated: true, completion: nil)
    }
    
    // Add User Delegate
    func addUsersToGroup(users: [User]) {
        for user in users {
            // Add the user to the group tree
            database.child("groups").child(group.uid).child("members").child(user.uid).setValue(user.handle)
            
            // Add the group to the users list of groups
            database.child("users").child(user.uid).child("groups").child(group.uid).setValue(group.name)
            
            group.members.append(user)
            
            // Add the user to the collection view
            collectionView.insertItems(at: [IndexPath(row: 0, section: 0)])
        }
    }
    
    // Load all of the profile photos for the users
    func loadMembers() {
        // Praying the members are loaded by now
        for i in 0..<group.members.count {
            let member = group.members[i]
            
            storage.child("users").child(member.uid).child("profilePhoto.jpg").getData(maxSize: MAX_PROFILE_PHOTO_SIZE, completion: { (data, error) in
                if error == nil {
                    member.profilePhoto = UIImage(data: data!)
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadItems(at: [IndexPath(item: i, section: 0)])
                    }
                    
                } else {
                    print("ERROR LOADING \(member.uid) PROFILE PHOTO")
                    print(error!)
                    return
                }
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "groupSettingsToAddUserSegue" {
            if let vc = segue.destination as? AddUserViewController {
                // Set the delegate to add new users to the collectionView and database
                vc.addUsersDelegate = self
                vc.group = group
            }
        }
    }
}

extension GroupSettingsViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "default", for: indexPath) as! GroupMemberCollectionViewCell
        
        cell.user = group.members[indexPath.item]
        cell.initialize()
        
        cell.tag = indexPath.item
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return group.members.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}
