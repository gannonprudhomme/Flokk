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
import FirebaseDatabase

// Used in CreateGroupViewController
protocol AddGroupDelegate {
    func createNewGroup(groupName: String, icon: UIImage)
}

// Used in GroupSettingsViewController
protocol LeaveGroupDelegate {
    func leaveGroup(group: Group)
}

class GroupsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var colorSelectionView: UIView!
    
    // Observer handle for listening to group changes
    var groupChangesHandle: UInt!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if Auth.auth().currentUser != nil && mainUser != nil {
            // User is completely signed in, act like normal
            
        } else if Auth.auth().currentUser != nil && mainUser == nil {
            // User is signed into Firebase, but the Flokk user isn't initialized yet
            // Load initial user data
            load {
                DispatchQueue.main.async {
                    //self.loadGroups()
                    self.tableView.reloadData() // I don't like using this
                }
                
                // Attach the observer for listening for group additions
                self.addListeners()
            }
            
        } else {
            performSegue(withIdentifier: "groupsToSignUpSegue", sender: nil)
            // No user is signed in, go to the sign in / sign up
            //let vc = UIStoryboard(name: "SignUp", bundle: nil).instantiateViewController(withIdentifier: "SignUpNavigationController")
            //present(vc, animated: false, completion: nil)
        }
        
        // TODO: Listen for group changes in users/mainUser.uid/groups
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // If we add a new group and don't call this, will it be added anyways?
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
                
                vc.leaveGroupDelegate = self
            }
        }
    }
}

// MARK: - Framework functions
extension GroupsViewController {
    // Load the groups into the main user
    func loadGroups() {
        // what would even be loaded here?
        // Maybe request the group Icons
        
    }
    
    // WIP new way of loading data, both locally
    func load(completion: @escaping () -> Void) {
        let uid = Auth.auth().currentUser?.uid
        
        // Attempt to load from the local file first
        if /*uid == ""*/ let value = FileUtils.loadJSON(file: "users/mainUser.json") {
            print(value)
            processUserData(value)
            
            // Then download the new data anyways and compare with the loaded data
                // Only need to compare what groups the user is in
                // As in, if the user was invited to a group when they weren't in the app
                // Need to match the groups that are together and perhaps remove them from the comparison(on both sides)
                // In case this user is removed from a group, but also added to a new different one
            database.child("users").child(mainUser.uid).child("groups").observeSingleEvent(of: .value, with: { (snapshot) in
                if let value = snapshot.value as? [String : Any] {
                    // Compare the groups with the existing groups
                    
                    var newGroupIDs = Array(value.keys) // Ends up being the groups to add
                    var oldGroups = mainUser.groups // Ends up being the groups to remove
                    
                    // Iterate over both groups, and remove the matches from both arrays
                    for var (i, newID) in newGroupIDs.enumerated().reversed() {
                        //let newID = newGroupIDs[i]
                        
                        // Iterate over the old group
                        for (j, group) in oldGroups.enumerated().reversed() {
                            let oldID = group.uid
                            
                            // If the uid's match
                            if newID == oldID {
                                // Remove the value from both arrays
                                newGroupIDs.remove(at: i)
                                oldGroups.remove(at: j)
                            }
                        }
                    }
                    
                    // After removing all the matches, add and remove the according groups
                   
                    // print("\(newGroupIDs.count) new groups to add!")
                    
                    // Add all the new groups, if there are any
                    for groupID in newGroupIDs {
                        // Now that we know what data we need to process, get the according data from the database
                        
                        database.child("groups").child(groupID).observeSingleEvent(of: .value, with: { (snapshot) in
                            if let groupValue = snapshot.value as? [String : Any] {
                                print("Inserting new group \(groupID)")
                                let groupName = groupValue["name"] as! String
                                let group = Group(uid: groupID, name: groupName)
                                
                                self.joinedNewGroup(group: group)
                                
                                // TODO: Place this in a better place
                                //
                                print(mainUser.convertToDict())
                                FileUtils.saveToJSON(dict: mainUser.convertToDict(), toPath: "users/mainUser.json")
                            }
                        })
                    }
                    
                    mainUser.uid = mainUser.uid
                    // Save the (possibly) updated groups to the file system
                    //FileUtils.saveToJSON(dict: mainUser.convertToDict(), toPath: "users/mainUser.json")
                    completion()
                    
                    // How inefficient is this?
                    // Will it ever be a problem with the table view if the cells aren't inserterd/refreshed into the tableView
                    for group in oldGroups {
                        // Remove the group from the user's groups
                        print("Removing group \(group.uid)")
                        
                        let index = mainUser.groups.index(where: { $0.uid == group.uid})!
                        mainUser.groups.remove(at: index)
                        
                        // Remove the group from the tableView
                        DispatchQueue.main.async {
                            self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                        }
                    }
                }
            })
            
        } else {
            // Load directly from the database into the user data
            // Save the data
            // For now, using the old data loading function cause it gets the job done
            loadUserData {
                completion()
            }
        }
    }
    
    // Load the Flokk user data from the database
    func loadUserData(completion: @escaping () -> Void) {
        // Will never be nil, as this is only called after confirming the user is signed in
        let uid = Auth.auth().currentUser?.uid
        
        // TODO: Check if the data is stored locally, if it's not stored the json data into it, and load it the same way?
        // Or should we load it into memory and write into it
        /*if let value = FileUtils.loadJSON(file: "users/mainUser.json")  { // If the file exists locally
            print("Loading user data from disk")
            
            processUserData(value)
            
            // Done loading in the data
            completion()
        } else */ if uid != "" {
            // Load it from the dastabase
            database.child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                if let value = snapshot.value as? [String : Any] {
                    self.processUserData(value)
                    
                    // Write the current user data
                    FileUtils.saveToJSON(dict: value, toPath: "users/mainUser.json")
                    
                    completion()
                    
                    // Load in the profile photo
                    // Does not matter when this is loaded(in regards to calling completion())
                    storage.child("users").child(mainUser.uid).child("profilePhoto.jpg").getData(maxSize: MAX_PROFILE_PHOTO_SIZE, completion: { (data, error) in
                        if error == nil {
                            mainUser.profilePhoto = UIImage(data: data!)
                            
                            // TODO: Save the user's photo if it is not saved already
                        } else {
                            print(error!)
                            return
                        }
                    })
                }
            })
        }
    }
    
    // Helper function for processing the user data from a dictionary
    private func processUserData(_ value: [String : Any]) {
        let uid = Auth.auth().currentUser?.uid
        
        let handle = value["handle"] as! String
        let fullName = value["name"] as! String
        
        mainUser = User(uid: uid!, handle: handle)
        mainUser.fullName = fullName
        
        // Attempt to load in the group IDs
        if let groups = value["groups"] as? [String : String] {
            // Load in each of the groupIDs
            for groupID in groups.keys {
                let groupName = groups[groupID]
                
                let group = Group(uid: groupID, name: groupName!)
                
                mainUser.groups.append(group)
                
                // Attempt to download the group icon
                group.requestGroupIcon(completion: { (icon) in
                    if let icon = icon {
                        // Once it's loaded, set it in the group
                        group.setIcon(icon: icon)
                        
                        // TODO: Review this operation
                        // And updated the according row
                        DispatchQueue.main.async {
                            // Have to do this because simply counting
                            var index = -1
                            for i in 0..<mainUser.groups.count {
                                if mainUser.groups[i].uid == group.uid {
                                    index = i
                                }
                            }
                            
                            // Reload the row
                            self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                        }
                    }
                })
            }
        }
    }
    
    // TODO: Consider moving this function to a separate class
    // Used in load() and processUserData()
    
    private func processGroupData(uid: String, value: [String : Any]) {
        if let data = value[uid] as? [String : Any] {
            let groupName = data["groupName"] as! String
            let group = Group(uid: uid, name: groupName)
            
            // Add the new group to the global list
            mainUser.groups.append(group)
            
            // Insert the group in the first row, without checking what timestamp it's at
            DispatchQueue.main.async {
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            }
            
            // Attempt to download the group icon
            group.requestGroupIcon(completion: { (icon) in
                if let icon = icon {
                    // Once it's loaded, set it in the group
                    group.setIcon(icon: icon)
                    
                    // TODO: Review this operation
                    // And updated the according row
                    DispatchQueue.main.async {
                        // Have to do this because simply counting
                        var index = -1
                        for i in 0..<mainUser.groups.count {
                            if mainUser.groups[i].uid == group.uid {
                                index = i
                            }
                        }
                        
                        // Reload the row
                        self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                    }
                }
            })
        }
    }
    
    // Adds observers listening for changes in the database
    func addListeners() {
        
        // Begin listening for changes to the mainUser's groups. Called if another user removes/adds the mainUser to a group
        groupChangesHandle = database.child("users").child(mainUser.uid).child("groups").observe(.value, with: { (snapshot) in
            if let value = snapshot.value as? [String : Any] {
                // Iterate through all of the groups, checking for which one is new
                for newGroupID in value.keys {
                    let groupName = value[newGroupID] as! String
                    var isNewGroup = true
                    
                    // Check if the groupID is listed in mainUser.groups
                    for group in mainUser.groups {
                        if newGroupID == group.uid { // If this new groupID matches an existing groupID
                            isNewGroup = false // Then this isn't a new group, skip
                        }
                    }
                    
                    // If this is a new group
                    if isNewGroup {
                        print("Joining new group \(newGroupID)")
                        // Initialize it
                        self.joinedNewGroup(group: Group(uid: newGroupID, name: groupName))
                    }
                }
            }
        })
    }
    
    // Called when a remote user adds this user to their group
    func joinedNewGroup(group: Group) {
        // add it to the user's groups array
        mainUser.groups.insert(group, at: 0)
        
        // Insert the new group into the tableView
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        
        // Attempt to download the group icon
        group.requestGroupIcon(completion: { (icon) in
            if let icon = icon {
                // Once it's loaded, set it in the group
                group.setIcon(icon: icon)
                
                // And updated the according row
                DispatchQueue.main.async {
                    // This is so fucking stupid
                    // Have to do this because simply counting
                    var index = -1
                    for i in 0..<mainUser.groups.count {
                        if mainUser.groups[i].uid == group.uid {
                            index = i
                        }
                    }
                    
                    // Reload the row
                    self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                }
            }
        })
    }
    
    // Called when a new post is added, should be a delegate?
    func groupUpdated(group: Group) {
        // Update the mainUsers' groups array, and get the index(row) this group is located at
        let row = mainUser.groupUpdated(group: group)
        
        
        // Move the row to the top
        tableView.moveRow(at: IndexPath(row: row, section: 0), to: IndexPath(row: 0, section: 0))
        
        // TODO: Update the timestamp
    }
}

// MARK: - Delegate functions for adding and leaving groups
extension GroupsViewController: AddGroupDelegate, LeaveGroupDelegate {
    // GroupsViewControllerDelegate function, called from CreateGroupVC
    func createNewGroup(groupName: String, icon: UIImage) {
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
    
    // LeaveGroupDelegate. Called from GroupSettingsVC
    func leaveGroup(group: Group) {
        // If there is only one member, delete the group completely
        if group.members.count == 1 {
            // Remove it from the groups tree
            database.child("groups").child(group.uid).removeValue()
            
            // Remove the group icon from storage
            storage.child("groups").child(group.uid).child("icon.jpg").delete(completion: { (error) in
                if let error = error {
                    print(error)
                    return
                }
            })
            
            // Iterate through all of the posts and delete them from storage
            for post in group.posts {
                // Remove all of the storage files for it
                storage.child("groups").child(group.uid).child("posts").child(post.uid).delete(completion: { (error) in
                    if let error = error {
                        print(error)
                        return
                    }
                })
            }
        }
        
        // Remove the group from the user's list of groups in the database
        database.child("users").child(mainUser.uid).child("groups").child(group.uid).removeValue()
        
        // Remove the user from the group's members list
        database.child("groups").child(group.uid).child("members").child(mainUser.uid).removeValue()
        
        // Find the row/index of the group to be removed
        var index = -1
        for i in 0..<mainUser.groups.count {
            if mainUser.groups[i].uid == group.uid {
                index = i
                break // Found the group, stop looping
            }
        }
        
        // If the group was found(should be always)
        if index >= 0 {
            // Remove the group from the user's groups array
            mainUser.groups.remove(at: index)
            
            // Delete the row from the tableView
            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }

    @IBAction func unwindToGroups(segue: UIStoryboardSegue) {}
}

extension GroupsViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath as IndexPath) as! GroupsTableViewCell
        
        cell.group = mainUser.groups[indexPath.row]
        cell.tag = indexPath.row
        cell.initialize()
        cell.selectedBackgroundView = colorSelectionView
        
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
