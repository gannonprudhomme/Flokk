//
//  Networking.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 8/28/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import Foundation

// Functions for processing the Group and Feed data within Flokk
// Includes:
// - Loading the initial data, and manipulating the table cells for the according groups
//   - this includes handling the local data, then loading in the databsae data and handling it accordingly
// - adding observers for new groups/posts and all of the functions incorborated with them

extension User {
    
}

extension Group {
    
}

// For use in indexForUpdatedGroup
// From: https://stackoverflow.com/questions/26678362/how-do-i-insert-an-element-at-the-correct-position-into-a-sorted-array-in-swift
extension Array {
    func insertionIndexOf(elem: Element, isOrderedBefore: (Element, Element) -> Bool) -> Int {
        var lo = 0
        var hi = self.count - 1
        while lo <= hi {
            let mid = (lo + hi)/2
            if isOrderedBefore(self[mid], elem) {
                lo = mid + 1
            } else if isOrderedBefore(elem, self[mid]) {
                hi = mid - 1
            } else {
                return mid // Found at position mid
            }
        }
        return lo // Not found, would be inserted at position lo
    }
}

extension GroupsViewController {
    func indexForUpdatedGroup(group: Group) -> Int {
        if mainUser.groups.count > 1 {
            let mostRecentGroup = mainUser.groups[0]
            
            // If the top-most group and argument are the same group
            if group.uid == mostRecentGroup.uid {
                return 0
            }
            
            // If this is going to be the most recently updated group regardless
            if group.newestPostTime > mostRecentGroup.newestPostTime {
                return 0
            }
        }
        
        // Otherwise, do a binary search for where this group will be
        return mainUser.groups.insertionIndexOf(elem: group) {$0.newestPostTime < $1.newestPostTime }
    }
    
    fileprivate func removeMatchingMembers(oldMembers: inout [User], newMemberUIDs: inout [String])  {
        for(i, oldMember) in oldMembers.enumerated().reversed(){
            for (j, newUID) in newMemberUIDs.enumerated().reversed() {
                if oldMember.uid == newUID {
                    oldMembers.remove(at: i)
                    newMemberUIDs.remove(at: j)
                }
            }
        }
    }
}
