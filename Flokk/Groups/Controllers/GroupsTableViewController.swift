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
class GroupsTableViewController: UITableViewDatasource, UITableViewDelegate {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = FeedViewController()
        
        vc.group = mainUser.groups[indexPath.row]
        vc.group.feedDelegate = vc
        vc.leaveGroupDelegate = self
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
}
