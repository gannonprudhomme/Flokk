//
//  GroupSpec.swift
//  FlokkTests
//
//  Created by Gannon Prudhomme on 12/28/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import XCTest

class GroupSpec: XCTestCase {
    override func setUp() {
    }

    override func tearDown() {
    }
    
    func testGroupDatabaseLoading() {
        
    }
    
    // Helper function for creation a dictionary
    func createGroupDict(name: String?, creator: String?, creationDate: Double?, members: [String: String]?) -> [String: Any] {
        var data = [String : Any]()
        
        // If any of these values are included(not nil), add them to the group dictionary
        
        if let _ = name {
            data["name"] = name
        }
        
        if let _ = creator {
            data["creator"] = creator
        }
        
        if let _ = creationDate {
            data["creationDate"] = creationDate
        }
        
        if let _ = members {
            data["members"] = members
        }
        
        print(data)
        
        return data
    }
}
