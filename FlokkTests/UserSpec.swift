//
//  UserSpec.swift
//  FlokkTests
//
//  Created by Gannon Prudhomme on 12/28/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import XCTest

class UserSpec: XCTestCase {
    override func setUp() {
    }

    override func tearDown() {
    }
    
    // Test loading the test user from the database
    func testUserLoadFromDatabase() {
        var user = UserModel(uid: "B7aPv6ytLdOFUskBcYkj66WfjIg2") // uid of the testuser, retrieved manually
        
        let expect = expectation(description: "Test User Loading")
        
        user.loadUserFromDatabase().then({ retUser in
            XCTAssertEqual(retUser.handle, user.handle)
            XCTAssertEqual(user.handle, "testuser")
            XCTAssertEqual(user.fullName, "Test User")
            
            expect.fulfill()
        }).catch({error in
            XCTAssert(false)
        })
        
        // Wait for 3 seconds for the database call to return before evaluating this test
        wait(for: [expect], timeout: 5)
    }

    // Test processing user data with all data present
    func testUserDataProcessing() {
        let groups: [String : String] = [
            "group1": "idk"
        ]
        
        let data = createUserDict(handle: "handle", fullName: "Full Name", groups: groups)
        
        let userModel = UserModel(uid: "uid")
        do {
            try userModel.processUserData(data)
            
            XCTAssertEqual("uid", userModel.uid)
            XCTAssertEqual("handle", userModel.handle)
            XCTAssertEqual("Full Name", userModel.fullName)
            XCTAssertEqual(["group1"], userModel.groups)
            // Ignore groups for now
        } catch UserLoadingError.processDataError(let errorMessage) {
            print(errorMessage)
            XCTAssert(false) // An error was thrown, fail the test
        } catch {
            XCTAssert(false) // An error was thrown, fail the test
        }
    }
    
    // Test processing user data with a nil handle, should return an error
    func testNilUserDataProcessing1() {
        let data = createUserDict(handle: nil, fullName: "Full Name", groups: nil)
        
        let userModel = UserModel(uid: "uid")
        do {
            try userModel.processUserData(data)
            
            XCTAssert(false) // Didn't thrown an error, fail the test
        } catch UserLoadingError.processDataError(_) {
            XCTAssert(true) // An error was thrown(as expected), pass the test
        } catch {
            XCTAssert(false) // Not the error we're expecting to be thrown, fail the t3est
        }
    }
    
    // Test processing user data with a nil fullName, should return an error
    func testNilUserDataProcessing2() {
        let data = createUserDict(handle: "handle", fullName: nil, groups: nil)
        
        let userModel = UserModel(uid: "uid")
        do {
            try userModel.processUserData(data)
            
            XCTAssert(false) // Didn't thrown an error, fail the test
        } catch UserLoadingError.processDataError(_) {
            XCTAssert(true) // An error was thrown(as expected), pass the test
        } catch {
            XCTAssert(false) // Not the error we're expecting to be thrown, fail the t3est
        }
    }
    
    // Helper function for creation a dictionary
    func createUserDict(handle: String?, fullName: String?, groups: [String: String]?) -> [String: Any] {
        var data = [String : Any]()
        
        // If any of these values are included(not nil), add them to the group dictionary
        
        if let _ = handle {
            data["handle"] = handle
        }
        
        if let _ = fullName {
            data["name"] = fullName
        }
        
        if let _ = groups {
            data["groups"] = groups
        }
        
        return data
    }
}
