//
//  AddUserViewController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 8/14/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import UIKit

class AddUserViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var colorSelectionView: UIView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var addUsersDelegate: AddUserDelegate! = nil
    
    // Users that are displayed in the search results. tableView data source
    var userResults = [User]()
    
    // Users the mainUser has selected to invite. collectionView data source
    var selectedUsers = [User]()
    
    // Reference to the group we're in. Used for checking if the selected user is a member
    // before attempting to invite them/add them to the group
    var group: Group!
    
    var numEmptyCells = 6
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        //searchController.searchBar.tintColor = UIColor(named: "Flokk Navy")
        searchController.searchBar.barTintColor = UIColor(named: "Secondary Navy")
        searchController.searchBar.keyboardAppearance = .dark
        searchController.searchBar.layer.cornerRadius = searchController.searchBar.bounds.width / 2
        searchController.searchBar.placeholder = "Enter a username"
        
        // Set font for search bar
        //UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).setTitleTextAttributes([NSAttributedStringKey.font : UIFont(name: "OpenSans", size: 15)!], forState: .Normal)
    
        // Set the search bar as the header of the tableView
        tableView.tableHeaderView = searchController.searchBar
        
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.singleTap(sender:)))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.isEnabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(singleTapGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Invite all of the selected users
    @IBAction func invitePressed(_ sender: Any) {
        if selectedUsers.count == 0 {
            // If there were no users selected, display an error
        } else {
            addUsersDelegate.addUsersToGroup(users: selectedUsers)
            // TODO: Show an alert confirming that these users were invited
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //searchController.searchBar.isHidden = true
    }
}

extension AddUserViewController :  UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath) as! UserSearchTableViewCell
        
        cell.user = userResults[indexPath.row]
        cell.initialize()
        cell.selectedBackgroundView = colorSelectionView
        
        cell.tag = indexPath.row
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = userResults[indexPath.row]
        
        // If this user is not already a member
        if !group.members.contains(where: { $0.uid == user.uid}) {
            
            // If this user is not selected
            if !selectedUsers.contains(where: { $0.uid == user.uid }) {
                // Add the selected user to the array
                selectedUsers.append(user)
                
                if selectedUsers.count < numEmptyCells {
                    collectionView.reloadItems(at: [IndexPath(item: selectedUsers.count - 1, section: 0)])
                } else {
                    collectionView.reloadData()
                    //collectionView.insertItems(at: [IndexPath(item: selectedUsers.count - 1, section: 0)])
                }
            } else { // User is already selected
                // Remove it from the collectionView?
                
                
            }
        } else { // User is already a member of this group
            // TODO: Give feedback notifying the mainUser that the user is already a member
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userResults.count
    }
}

// MARK: - Collection View functions
extension AddUserViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "default", for: indexPath) as! UserSearchCollectionViewCell

        if indexPath.item < selectedUsers.count {
            cell.user = selectedUsers[indexPath.item]
            cell.initialize()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // For adding "ghost" icons
        if selectedUsers.count <= numEmptyCells {
            return numEmptyCells
        } else {
            return selectedUsers.count
        }
    }
    
    @objc func singleTap(sender: UITapGestureRecognizer) {
        // Deselect the
        self.searchController.searchBar.resignFirstResponder()
    }
}

// MARK: - Search Bar functions
extension AddUserViewController : UISearchBarDelegate, UISearchResultsUpdating {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchText = searchBar.text!
        let searchRef = database.child("users").queryOrdered(byChild: "handle").queryStarting(atValue: searchText)
        
        // Clear all the previous results
        userResults.removeAll()
        tableView.reloadData()
        
        searchRef.observe(.value, with: { (snapshot) in
            if let value = snapshot.value as? [String : Any] {
                for uid in value.keys {
                    if uid != mainUser.uid {
                        let userData = value[uid] as! [String : Any]
                        let handle = userData["handle"] as! String
                        
                        // Compare the searchText with the user's handle
                        let minLength = min(handle.count, searchText.count)
                        var isEqual = true // If the portion of the handle and searchText are
                        for i in 0..<minLength {
                            // Get the according indices for the character to compare
                            let handleIndex = handle.index(handle.startIndex, offsetBy: i)
                            let searchIndex = searchText.index(searchText.startIndex, offsetBy: i)
                            
                            // Only compare the lowercased strings
                            if handle.lowercased()[handleIndex] != searchText.lowercased()[searchIndex] {
                                isEqual = false
                            }
                        }
                        
                        // If the handle and searchText are equal, download the profilePhoto and add the user to the tableView
                        if isEqual {
                            storage.child("users").child(uid).child("profilePhoto.jpg").getData(maxSize: MAX_PROFILE_PHOTO_SIZE, completion: { (data, error) in
                                if error == nil {
                                    let profilePhoto = UIImage(data: data!)
                                    
                                    let user = User(uid: uid, handle: handle, profilePhoto: profilePhoto!)
                                    
                                    self.userResults.append(user)
                                    
                                    // Insert the row into the last index
                                    self.tableView.insertRows(at: [IndexPath(row: self.userResults.count - 1, section: 0)], with: .bottom)
                                } else {
                                    print(error!)
                                    return
                                }
                            })
                        }
                    }
                }
            }
        })
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchBar.text == "" { // If the searchBar text is empty
            // Remove all of the search results
            userResults.removeAll()
            tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // If the search is cancelled, remove all of the users if there were any
        userResults.removeAll()
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        print("update")
    }
}
