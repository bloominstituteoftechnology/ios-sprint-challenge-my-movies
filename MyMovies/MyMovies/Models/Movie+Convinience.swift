//
//  Movie+Convinience.swift
//  MyMovies
//
//  Created by Iyin Raphael on 9/28/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    convenience init (title: String, hasWatched: Bool, identifier: UUID, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        
        self.title = title
        self.hasWatched = hasWatched
        self.identifier = identifier
    }
}
