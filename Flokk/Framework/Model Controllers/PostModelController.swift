//
//  PostModelController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 12/24/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import Foundation
import Promises

// Provides extra functions for the PostModel that would clog up the PostModel file
extension PostModel {
    func loadPostFromStorage() -> Promise<PostModel> {
        return Promise { fulfill, reject in
            // Retrieve the data from the databse
                // If it doesn't exist, reject the Promise
            
            fulfill(self)
        }
    }
}
