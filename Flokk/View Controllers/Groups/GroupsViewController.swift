//
//  GroupsViewController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 8/7/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

protocol GroupsViewControllerDelegate {
    func addNewGroup(groupName: String, icon: UIImage)
}

class GroupsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if Auth.auth().currentUser != nil && mainUser != nil {
            // User is completely signed in, act like normal
            
            
        } else if Auth.auth().currentUser != nil && mainUser == nil {
            // User is signed into Firebase, but the Flokk user isn't initialized yet
            // Load initial user data
            loadUserData(completion:{ () in
                // Do something
                DispatchQueue.main.async {
                    self.loadGroups()
                    self.tableView.reloadData()
                }
            })
            
        } else {
            // No user is signed in, go to the sign in / sign up
            let vc = UIStoryboard(name: "SignUp", bundle: nil).instantiateViewController(withIdentifier: "SignUpNavigationController")
            present(vc, animated: false, completion: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "groupsToCreateGroupSegue" {
            if let vc = segue.destination as? CreateGroupViewController {
                // Set the create group's delegate at this class, in order to send the new group data back
                vc.delegate = self
            }
        } else if segue.identifier == "groupsToFeedSegue" {
            if let vc = segue.destination as? FeedViewController {
                // Get the according group from the selected cell
                if let tag = (sender as? GroupsTableViewCell)?.tag {
                    vc.group = mainUser.groups[tag]
                }
            }
        }
    }
}

// MARK: - Framework functions
extension GroupsViewController : GroupsViewControllerDelegate {
    // Load the groups into the main user
    func loadGroups() {
        // what would even be loaded here?
        // Maybe request the group Icons
        
    }
    
    // Load the Flokk user data from the database
    func loadUserData(completion: @escaping () -> Void) {
        // Will never be nil, as this is only called after confirming the user is signed in
        let uid = Auth.auth().currentUser?.uid
        
        database.child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                let handle = value["handle"] as! String
                
                mainUser = User(uid: uid!, handle: handle)
                
                // Attempt to load in the group IDs
                if let groups = value["groups"] as? [String : String] {
                    // Load in each of the groupIDs
                    for groupID in groups.keys {
                        let groupName = groups[groupID]
                        
                        let group = Group(uid: groupID, name: groupName!)
                        
                        // Initialize the group and add it to the user's groups array
                        mainUser.groups.append(group)
                        
                        // Attempt to download the group icon
                        group.requestGroupIcon(completion: { (icon) in
                            if let icon = icon {
                                // Once it's loaded, set it in the group
                                group.setIcon(icon: icon)
                                
                                // TODO: Review this operation
                                // And updated the according row
                                DispatchQueue.main.async {
                                    // This is so fucking stupid
                                    // Have to do this because simply counting
                                    var index = -1
                                    for i in 0..<mainUser.groups.count {
                                        if mainUser.groups[i].uid == groupID {
                                            index = i
                                        }
                                    }
                                    
                                    // Reload the row
                                    self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                                }
                            }
                        })
                    }
                } else {
                    // No groups, do nothing I guess
                }
                
                // TODO: Also load in user's profile photo(later)
                
                completion()
            }
        })
    }
    
    func groupUpdated(group: Group) {
        // Update the mainUsers' groups array, and get the index(row) this group is located at
        let row = mainUser.groupUpdated(group: group)
        
        // Move the row to the top
        tableView.moveRow(at: IndexPath(row: row, section: 0), to: IndexPath(row: 0, section: 0))
    }
    
    // GroupsViewControllerDelegate function, called from CreateGroupVC
    func addNewGroup(groupName: String, icon: UIImage) {
        let groupID = database.ref.child("groups").childByAutoId().key
        
        // Add the data to the user tree
        database.ref.child("users").child(mainUser.uid).child("groups").child(groupID).setValue(groupName)
        
        // Add the data to the groups tree
        let groupRef = database.ref.child("groups").child(groupID)
        groupRef.child("name").setValue(groupName)
        groupRef.child("creator").setValue(mainUser.uid)
        //groupRef.child("creationDate").setValue(NSDate.timeIntervalSinceReferenceDate) // No purpose for this for now
        
        // Add the mainuser as a member
        groupRef.child("members").child(mainUser.uid).setValue(mainUser.handle)
        
        // Upload the icon to storage. We don't need to wait on this, so no need to do anything on completion
        storage.child("groups").child(groupID).child("icon.jpg").putData(icon.convertJpegToData())
        
        // Initialize the Group object and add it to the mainUser's groups array
        let group = Group(uid: groupID, name: groupName)
        group.setIcon(icon: icon)
        
        // Prepend this group to the groups array
        mainUser.groups.insert(group, at: 0)
        
        // Insert it into the top of the tableView, shifting the other
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .none)
    }
}

extension GroupsViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath as IndexPath) as! GroupsTableViewCell
        
        cell.group = mainUser.groups[indexPath.row]
        cell.tag = indexPath.row
        cell.initialize()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if mainUser != nil {
            return mainUser.groups.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
}
