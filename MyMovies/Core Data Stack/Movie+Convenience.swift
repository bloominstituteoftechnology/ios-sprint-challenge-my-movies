//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by brian vilchez on 10/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    
    convenience init(title: String, hasWatched: Bool = false, identifier: UUID, context: NSManagedObjectContext) {
        self.init(context: context)
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched
        
    }
}
