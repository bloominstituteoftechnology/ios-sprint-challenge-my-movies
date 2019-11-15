//
//  Entry+Convenience.swift
//  MyMovies
//
//  Created by Niranjan Kumar on 11/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    @discardableResult convenience init(title: String,
                                        identifier: UUID = UUID(),
                                        hasWatched: Bool, // ask question
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched // why is this coaselscing needed when I already provided default
    }
    
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard let hasWatched = movieRepresentation.hasWatched,
            let identifier = movieRepresentation.identifier else {
                return nil
        }
        
        self.init(title: movieRepresentation.title, identifier: identifier, hasWatched: hasWatched, context: context)
        
    }
    
    var movieRepresentation: MovieRepresentation? {
        guard let title = title else {
                return nil
        }
    
        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
    
    
    }
    
    
}


//movierepresentation: results.title,etc
