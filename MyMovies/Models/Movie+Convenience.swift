//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Hannah Bain on 8/15/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {

    @discardableResult convenience init(hasWatched: Bool,
                                        identifier: UUID = UUID(),
                                        title: String,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
    
    self.init(context: context)
    self.hasWatched = hasWatched
    self.identifier = identifier
    self.title = title

    }

}





