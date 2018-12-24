//
//  PostModelController.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 12/24/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import Foundation
import Promises

extension PostModel {
    func loadPostFromDatabase() -> Promise<PostModel> {
        return Promise { fulfill, reject in
            // Retrieve the data from the databse
                // If it doesn't exist, reject the Promise
            
            fulfill(self)
        }
    }
}
