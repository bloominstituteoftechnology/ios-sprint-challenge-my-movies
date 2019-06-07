//
//  Movie.swift
//  MyMovies
//
//  Created by Sameera Roussi on 6/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    convenience init(title: String, hasWatched: Bool = false, identifier: UUID? = UUID(), context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        //initialize the remaining values
        (self.title, self.hasWatched, self.identifier) = (title, hasWatched, identifier)
        
    }
}
