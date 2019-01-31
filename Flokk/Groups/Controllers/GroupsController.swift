//
//  GroupsController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 12/28/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import Foundation

// Handles any control involved with the Groups View (Controller)
// Handles group loading, authentication(?), 
class GroupsController {
    // Determine whether or not a user is signed in, and if their Flokk data is loaded
    // in yet.
    func handleAuthentication() {
        // If authenticated, but no Flokk user data
            // load user & group data
        
        // If not authenticated
            // Send the user to Sign Up / Log In
    }
    
    func initialLoad() {
        // Load relevant group data
        
    }
    
    // Ideally, not much logic in here
    func loadUserData() {
        // Call some other handler function to load the necessary user ddata for the main user
    }
    
    
}
