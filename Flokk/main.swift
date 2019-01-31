//
//  main.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 1/10/19.
//  Copyright © 2019 Gannon Prudomme. All rights reserved.
//

import UIKit

// For some reason, this is the only way that I can access the global variables in AppDelegate
//  when running tests
private func delegateClassName() -> String? {
    return NSClassFromString("XCTestCase") == nil ? "Flokk.AppDelegate" : "FlokkTests.AppDelegate"
}


UIApplicationMain(
    CommandLine.argc,
    UnsafeMutableRawPointer(CommandLine.unsafeArgv).bindMemory(to: UnsafeMutablePointer<Int8>.self, capacity: Int(CommandLine.argc)), nil, delegateClassName()
)
