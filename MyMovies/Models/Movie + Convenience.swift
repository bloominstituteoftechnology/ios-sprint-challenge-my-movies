//
//  Movie + Convenience.swift
//  MyMovies
//
//  Created by Rick Wolter on 11/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData




extension Movie {
   convenience init( title: String, hasWatched: Bool = false, identifier: UUID = UUID(), context: NSManagedObjectContext = CoreDataStack.shared.mainContext){
          self.init(context: context)
          self.title = title
          self.hasWatched = hasWatched
          self.identifier = identifier
          
      }
    convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
            
            guard let hasWatched = movieRepresentation.hasWatched,
                let identifier = movieRepresentation.identifier else { return nil }
            
            self.init(title: movieRepresentation.title, hasWatched: hasWatched, identifier: identifier, context: context)
        }
        
        var movieRepresentation: MovieRepresentation? {
            guard let title = self.title, let identifier = self.identifier else { return nil }
            
            return MovieRepresentation(title: title, identifier: identifier, hasWatched: self.hasWatched)
        }
    }
