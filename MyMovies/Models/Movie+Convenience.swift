//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Cameron Collins on 4/24/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData


extension Movie {
    
    //Initializer
    @discardableResult convenience init(identifier: UUID = UUID(), title: String, hasWatched: Bool, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(context: context)
        self.identifier = identifier
        self.title = title
        self.hasWatched = hasWatched
    }
    
}
