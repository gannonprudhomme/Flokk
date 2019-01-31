//
//  ProcessGroupDataSpec.swift
//  FlokkTests
//
//  Created by Gannon Prudhomme on 1/6/19.
//  Copyright © 2019 Gannon Prudomme. All rights reserved.
//

import XCTest

class ProcessGroupDataSpec: XCTestCase {
    override func setUp() {
    }

    override func tearDown() {
    }

    func testFullLoading() {
        let creatorUID = "someuid"
        let creationDate = 556859224.197221
        let groupName = "Some Name"
        let members: [String : String] = [creatorUID: "creatorHandle"]
        
        let data: [String : Any] = createGroupDict(name: groupName, creator: creatorUID, creationDate: creationDate, members: members)
        
        var groupModel = GroupModel(uid: "groupuid")
        do {
            try groupModel.processGroupData(data)
        } catch GroupLoadingError.processDataError(let errorMessage) {
            // print(errorMessage)
            XCTAssert(false) // Fail the test
        } catch {
            XCTAssert(false) // Fail the test
        }
        
        XCTAssertEqual(creatorUID, groupModel.creatorUID)
        XCTAssertEqual(creationDate, groupModel.creationDate)
        XCTAssertEqual(groupName, groupModel.name)
        XCTAssertEqual([creatorUID], groupModel.members)
        
        // TODO: Compare members
    }
    
    // Test error handling when name isn't in the group data
    func testNilGroupName() {
        let data: [String : Any] = createGroupDict(name: nil, creator: "somecreator", creationDate: 0, members: ["stuff": "stuff"])
        let groupModel = GroupModel(uid: "someuid")
        
        do {
            try groupModel.processGroupData(data)
            
            // Fail the test if .processGroupData didn't throw an error(and thus continued past the try line)
            XCTAssert(false)
        } catch GroupLoadingError.processDataError(_) {
            XCTAssert(true)
        } catch { // We're not trying to catch any other but .processDataError
            XCTAssert(false) // Thus, fail this test
        }
    }
    
    // Test error handling when creator isn't in the group data
    func testNilCreator() {
        let data: [String : Any] = createGroupDict(name: "Some Name", creator: nil, creationDate: 0, members: ["stuff": "stuff"])
        let groupModel = GroupModel(uid: "someuid")
        
        do {
            try groupModel.processGroupData(data)
            
            // Fail the test if .processGroupData didn't throw an error(and thus continued past the try line)
            XCTAssert(false)
        } catch GroupLoadingError.processDataError(_) {
            XCTAssert(true)
        } catch { // We're not trying to catch any other but .processDataError
            XCTAssert(false) // Thus, fail this test
        }
    }
    
    // Test error handling when creator isn't in the group data
    func testNilCreationDate() {
        let data: [String : Any] = createGroupDict(name: "Some Name", creator: "somecreator", creationDate: nil, members: ["stuff": "stuff"])
        let groupModel = GroupModel(uid: "someuid")
        
        do {
            try groupModel.processGroupData(data)
            
            // Fail the test if .processGroupData didn't throw an error(and thus continued past the try line)
            XCTAssert(false)
        } catch GroupLoadingError.processDataError(_) {
            XCTAssert(true)
        } catch { // We're not trying to catch any other but .processDataError
            XCTAssert(false) // Thus, fail this test
        }
    }
    
    func testNilMembers() {
        let data: [String : Any] = createGroupDict(name: "Some Name", creator: "somecreator", creationDate: 0, members: nil)
        let groupModel = GroupModel(uid: "someuid")
        
        do {
            try groupModel.processGroupData(data)
            
            // Fail the test if .processGroupData didn't throw an error(and thus continued past the try line)
            XCTAssert(false)
        } catch GroupLoadingError.processDataError(_) {
            XCTAssert(true)
        } catch { // We're not trying to catch any other but .processDataError
            XCTAssert(false) // Thus, fail this test
        }
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
        
        return data
    }

}
