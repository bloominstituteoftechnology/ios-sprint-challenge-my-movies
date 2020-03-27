//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Bradley Diroff on 3/27/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    var movieRepresentation: MovieRepresentation? {
        
        guard let identifier = identifier,
        let title = title else {return nil}
        
        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
    }
    
    @discardableResult convenience init(identifier: UUID = UUID(),
                     title: String,
                     hasWatched: Bool = false,
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(context: context)
        self.identifier = identifier
        self.title = title
        self.hasWatched = hasWatched
        
    }
    
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
      //  let theIdentifier = movieRepresentation.identifier ?? UUID()
    //    else {return nil}
        
        self.init(identifier: movieRepresentation.identifier ?? UUID(),
                  title: movieRepresentation.title,
                  hasWatched: movieRepresentation.hasWatched ?? false,
                  context: context)
        
    }
}

