//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Lambda_School_Loaner_218 on 12/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import CoreData
import Foundation

extension Movie {

    var movieRepresentation: MovieRepresentation? {
        guard let title = title, let identifier = identifier else { return nil }
        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
    }
    
    @discardableResult convenience init(title: String, identifier: UUID = UUID(),hasWatched: Bool ,context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(context: context)
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched ?? false
    }
    
    @discardableResult convenience init?(movieRep: MovieRepresentation,
                                         context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard let hasWatched = movieRep.hasWatched, let identifier = movieRep.identifier else  { return nil }
        self.init(title: movieRep.title, identifier:identifier, hasWatched: hasWatched, context: context)
        
    }
}
