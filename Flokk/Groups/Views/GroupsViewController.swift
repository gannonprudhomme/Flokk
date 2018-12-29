//
//  GroupsViewController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 12/28/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import UIKit

// AddGroupDelegate, for CreateGroupViewController
// LeaveGroupDelegate, for GroupSettingsViewController
// SortGroupsDelegate, for ?

// Should I consider renaming this to GroupsView or GroupsViewC
class GroupsViewController: UIViewController {
    // When should I initialize these
    private var groupsController = GroupsController()
    private var tableViewController =  GroupsTableViewController()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize Groups controller

        // Set tableView delegate & data source
        tableView.delegate = tableViewController
        tableView.dataSource = tableViewController
        
        // Handle User Authentication
        groupsController.handleAuthentication()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
}

// Table View interfacing functions for use from GroupsController
extension GroupsViewController {
    
}
