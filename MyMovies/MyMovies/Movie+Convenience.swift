//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Carolyn Lea on 8/25/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie
{
    convenience init(title: String, identifier: UUID = UUID(), hasWatched: Bool = false, context: NSManagedObjectContext = CoreDataStack.shared.mainContext)
    {
        self.init(context: context)
        
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched
    }
    
    convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext)
    {
        guard let identifier = movieRepresentation.identifier else {return nil}
        
        self.init(title: movieRepresentation.title, identifier: identifier, hasWatched: movieRepresentation.hasWatched!)
    }
    
    var movieRepresentation: MovieRepresentation?
    {
        guard let title = title else {return nil}
        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
    }
}
