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
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testGroupProcessing() {
        var creatorUID = "someuid"
        var creationDate = 556859224.197221
        var groupName = "Some Name"
        var members: [String : String] = [creatorUID: "creatorHandle"]
        
        var data: [String : Any] = [
            "creator": creatorUID,
            "creationDate": creationDate,
            "name": groupName,
            "members": members
        ]
        
        var groupModel = GroupModel(uid: "groupuid")
        groupModel.processGroupData(data)
        
        XCTAssertEqual(creatorUID, groupModel.creatorUID)
    }
}
