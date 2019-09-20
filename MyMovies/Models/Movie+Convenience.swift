//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Alex Rhodes on 9/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    
    @discardableResult convenience init? (title: String, identifier: String = UUID().uuidString, hasWatched: Bool = false, context: NSManagedObjectContext) {
        
        self.init(context: context)
        
        self.hasWatched = hasWatched
        self.title = title
        self.identifier = identifier
        
    }
    
    
    
    
}
