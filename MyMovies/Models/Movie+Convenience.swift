//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Enrique Gongora on 2/28/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    // This computed property allows any managed object to become a MovieRepresentation for sending to Firebase
    var movieRepresentation: MovieRepresentation? {
        guard let title = title else { return nil }
        if identifier == nil {
            identifier = UUID()
        }
        
        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
    }
    
    // This created a new managed object from raw data
    @discardableResult convenience init(title: String, identifier: UUID = UUID(), hasWatched: Bool = false, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched
    }
    
    // This creates a managed object from a MovieRepresentation object (which comes from Firebase)
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard let identifier = movieRepresentation.identifier, let hasWatched = movieRepresentation.hasWatched else { return nil }
        self.init(title: movieRepresentation.title,
                  identifier: identifier,
                  hasWatched: hasWatched,
                  context: context)
    }
}
