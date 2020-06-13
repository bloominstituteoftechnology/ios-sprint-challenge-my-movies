//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Bohdan Tkachenko on 6/13/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    // MARK: Properties
    //Computed Property
    
    var movieRepresentation: MovieRepresentation? {
        guard let title = title else { return nil }
        let id = identifier ?? UUID()
        return MovieRepresentation(title: title, identifier: id, hasWatched: hasWatched)
    }
    
    
    
    
    
    // MARK: Convenience init
    @discardableResult convenience init(identifier: UUID = UUID(),
                                        title: String,
                                        hasWatched: Bool = false,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.identifier = identifier
        self.title = title
        self.hasWatched = hasWatched
    }
    
    
    // Convenience init for JSON
    
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext){
        guard let identifier = movieRepresentation.identifier else { return nil}
        
        self.init(identifier: identifier,
                  title: movieRepresentation.title,
                  hasWatched: movieRepresentation.hasWatched ?? false,
                  context: context)
        
    }
    
}
