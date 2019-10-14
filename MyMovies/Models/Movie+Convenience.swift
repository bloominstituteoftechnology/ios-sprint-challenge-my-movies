//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Vici Shaweddy on 10/12/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    convenience init(title: String, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        
        self.title = title
    }
    
    convenience init(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        
        self.title = movieRepresentation.title
    }
    
    @objc func hasWatchedSectionName() -> String {
        return self.hasWatched ? "Watched" : "Unwatched"
    }
    
    var movieRepresentation: MovieRepresentation? {
        guard let title = title else { return nil }
        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
    }
}
