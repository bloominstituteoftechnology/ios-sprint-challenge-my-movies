//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by John Pitts on 6/14/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    convenience init(title: String, identifier: UUID = UUID(), hasWatched: Bool = false, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(context: context)  // this needs to be first
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched
    }
}
