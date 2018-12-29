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
    // Instance of GroupsController?
    
    @IBOutlet weak var tableView: UITableview
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set tableView delegate & data source
        
        // Handle User Authentication
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}

// Table View functions for use from GroupsController
extension GroupsViewController {
    
}
