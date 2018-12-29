//
//  GroupsTableViewController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 12/28/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import Foundation
import UIKit

// Deals with anything related to the table view within GroupsViewController
class GroupsTableViewController: NSObject, UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath as IndexPath) // as! GroupsTableViewCell
        
        // cell.group = mainUser.groups[indexPath.row]
        // cell.tag = indexPath.row
        // cell.initialize()
        //cell.selectedBackgroundView = colorSelectionView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if mainUser != nil {
            return 0
            //return mainUser.groups.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Initialize a new FeedViewController
       //let vc = FeedViewController()
        
        // Set the according group values
        //vc.group = mainUser.groups[indexPath.row]
        //vc.group.feedDelegate = vc
        //vc.leaveGroupDelegate = self
        
        // Deselect the row to make sure it doesn't stay highlighted when we segue back
        //tableView.deselectRow(at: indexPath, animated: false)
        
        // Segue to the FeedViewController, keeping it in the same nav controller
        //self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
}
