//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Jocelyn Stuart on 2/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import CoreData

extension Movie {
    
    @discardableResult convenience init(title: String, hasWatched: Bool, identifier: UUID = UUID(),
                context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(context: context)
        
        self.title = title
        self.hasWatched = hasWatched
        self.identifier = identifier
    }
    
}
