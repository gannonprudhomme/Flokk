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
    
    let searchController = UISearchController(searchResultsController: nil)
    
    let addUsersDelegate: AddUserDelegate! = nil
    
    // Users that are displayed in the search results. tableView data source
    var userResults = [User]()
    
    // Users the mainUser has selected to invite. collectionView data source
    var selectedUsers = [User]()
    
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
        //searchController.searchBar.tintColor = UIColor(named: "Flokk Navy")
        searchController.searchBar.barTintColor = UIColor(named: "Secondary Navy")
        searchController.searchBar.keyboardAppearance = .dark
        searchController.searchBar.layer.cornerRadius = searchController.searchBar.bounds.width / 2
        
        // Set the search bar as the header of the tableView
        tableView.tableHeaderView = searchController.searchBar
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Invite all of the selected users
    @IBAction func invitePressed(_ sender: Any) {
        if selectedUsers.count == 0 {
            // If there were no users selected
        } else {
           addUsersDelegate.addUsersToGroup(users: selectedUsers)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}

extension AddUserViewController :  UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath) as! UserSearchTableViewCell
        
        cell.user = userResults[indexPath.row]
        cell.initialize()
        
        cell.tag = indexPath.row
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = userResults[indexPath.row]
        
        // If this user is selected
        if selectedUsers.contains(where: { $0.uid == user.uid }) {
            // Remove him from the selection?
            
        } else {
            // Add the selected user to the array
            selectedUsers.append(user)
            
            // And insert a new item for this user
            collectionView.insertItems(at: [IndexPath(row: selectedUsers.count - 1, section: 0)])
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
        
        if selectedUsers.count > 0 {
            cell.user = selectedUsers[indexPath.row]
            cell.initialize()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // For adding "ghost" icons
        if selectedUsers.count < 4 {
            return selectedUsers.count + 4
        } else {
            return selectedUsers.count
        }
    }
}

// MARK: - Search Bar functions
extension AddUserViewController : UISearchBarDelegate, UISearchResultsUpdating {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchRef = database.child("users").queryOrdered(byChild: "handle").queryStarting(atValue: searchBar.text)
        
        // Clear all the previous results
        userResults.removeAll()
        //tableView.reloadData()
        
        searchRef.observe(.value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                for uid in value.allKeys {
                    let uid = uid as! String
                    
                    if uid != mainUser.uid {
                        let userData = value[uid] as! [String : Any]
                        let handle = userData["handle"] as! String
                        
                        storage.child("users").child(uid).child("profilePhoto").getData(maxSize: MAX_PROFILE_PHOTO_SIZE, completion: { (data, error) in
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
    
    func updateSearchResults(for searchController: UISearchController) {}
}
