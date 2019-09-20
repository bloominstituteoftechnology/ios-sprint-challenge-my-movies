//
//  Movie.swift
//  MyMovies
//
//  Created by brian vilchez on 9/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    convenience init(hasWatched: Bool = false, title:String, identifier: String = UUID().uuidString, context: NSManagedObjectContext) {
        self.init(context: context)
        self.title = title
        self.hasWatched = hasWatched
        self.identifier = identifier
    }
    
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext) {
        guard let identifier = movieRepresentation.identifier,
        let hasWatched = movieRepresentation.hasWatched else {return nil}
        
        self.init(hasWatched:hasWatched ,title: movieRepresentation.title, identifier: identifier, context: context)
    }
    
    var movieRepresentation: MovieRepresentation {
        return MovieRepresentation(title: title!, identifier: identifier, hasWatched: hasWatched)
    }
}
