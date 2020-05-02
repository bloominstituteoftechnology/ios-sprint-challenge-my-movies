//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Lambda_School_Loaner_241 on 5/1/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

enum MoviePriority: String, CaseIterable {
    case Watched
    case Unwatched
}

extension Movie {
    @discardableResult convenience init(identifier: UUID = UUID(),title: String, hasWatched: Bool, context: NSManagedObjectContext = CoreDataStack.shared.mainContext){
        self.init(context: context)
        self.identifier = identifier
        self.title = title
        self.hasWatched = hasWatched
    }
    @discardableResult convenience init(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext){
        
        if let movieBool = movieRepresentation.hasWatched {
            
            if movieBool {
                let priority = MoviePriority(rawValue: "Watched")
                if let movieID = movieRepresentation.identifier {
                    let identifier = UUID(uuidString: movieID)
                }
            } else {
                let priority = MoviePriority(rawValue: "Unwatched")
                if let movieID = movieRepresentation.identifier {
                    let identifier = UUID(uuidString: movieID)
                }
            }
            
            
            
            
        }
    }
}

