//
//  MovieRepresentation+Convenience.swift
//  MyMovies
//
//  Created by Lambda_School_Loaner_34 on 2/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import CoreData

extension MovieRepresentation {
    
    @discardableResult convenience init(title: String, identifier: UUID? = UUID(), hasWatched: Bool?, context: NSManagedObjectContext = CoreDataStack.shared.mainContext {
        
        self.init(context: context)
        
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched
    }
    
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        guard let title = movieRepresentation.title else { return nil }
        
        self.init(title: movieRepresentation.title, identifier: movieRepresentation.identifier, hasWatched: movieRepresentation.hasWatched, context: context)
        
    }
    
    var movieRepresentation: MovieRepresentation? {
        
        guard let title = title,
        let identifier = identifier?,
            let hasWatched = hasWatched? else { return nil }
        
        let movieRepresentation = MovieRepresentation(title: title, identitifer: identifier, hasWatched: hasWatched)
        
        return movieRepresentation
        
    }
}
