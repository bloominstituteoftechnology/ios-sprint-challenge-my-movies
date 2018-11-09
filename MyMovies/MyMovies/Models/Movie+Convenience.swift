//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Lotanna Igwe-Odunze on 11/9/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie { //This should be extending the Movie in the data model.
    
    convenience init(
        title: String,
        identifier: UUID? = nil,
        hasWatched: Bool = false,
        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.title = title
        self.identifier = identifier ?? UUID()
        self.hasWatched = hasWatched
    }
    
    func grabMovie() -> MovieRepresentation {
        return MovieRepresentation(title: title, identifier: identifier!, hasWatched: hasWatched)
    }
    
    func assignMovie(movieRef: MovieRepresentation) {
        self.title = movieRef.title
        if let refIdentifier = movieRef.identifier {
            self.identifier = refIdentifier
        }
        
        if let refWatchStatus = movieRef.hasWatched {
            self.hasWatched = refWatchStatus
        }
        
    }
}
