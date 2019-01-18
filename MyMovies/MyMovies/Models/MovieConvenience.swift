//
//  MovieConvenience.swift
//  MyMovies
//
//  Created by Lotanna Igwe-Odunze on 1/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie { //The Movie in my data model.
    
    convenience init(
        title: String,
        identifier: UUID? = nil,
        hasWatched: Bool = false,
        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.title = title
        self.identifier = identifier ?? UUID() //If there is no identifier, make one
        self.hasWatched = hasWatched
    }
    
    //This returns an instance of the Movie with all properties unwrapped
    func getMovie() -> MovieRepresentation {
        return MovieRepresentation(title: title!, identifier: identifier!, hasWatched: hasWatched) }
    
    //This assigns an instance of the Movie Representation to the Core Data Model
    func assignMovie(tempMovie: MovieRepresentation) {
        
        self.title = tempMovie.title
        
        if let tempMovieID = tempMovie.identifier {
            self.identifier = tempMovieID
        }
        
        if let tempMovieStatus = tempMovie.hasWatched {
            self.hasWatched = tempMovieStatus
        }
        
    }
}//End of Convenience
