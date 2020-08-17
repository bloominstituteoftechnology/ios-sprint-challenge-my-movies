//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Eoin Lavery on 17/08/2020.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    @discardableResult convenience init(title: String,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.identifier = UUID()
        self.title = title
        self.hasWatched = false
    }
    
    @discardableResult convenience init(movie: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        let title = movie.title ?? "No Title"
        
        self.init(title: title, context: context)
    }
    
    var movieRepresentation: MovieRepresentation {
        return MovieRepresentation(identifier: identifier?.uuidString, title: title, hasWatched: hasWatched)
    }
    
}
