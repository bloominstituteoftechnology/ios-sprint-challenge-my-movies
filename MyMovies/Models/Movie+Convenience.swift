//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Sal Amer on 2/21/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData


extension Movie {
    
    var movieRepresentation: MovieRepresentation? {
        guard let title = title else { return nil }
        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
    }
    
   @discardableResult convenience init(title: String, identifier: UUID = UUID(), hasWatched: Bool = false, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched
        
    }
    
    // convinence init for Firebase
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
//         let title = movieRepresentation.title else { return nil }
//           guard let identifierString = movieRepresentation.identifier,
//            let identifier = UUID(uuidString: "identifierString"),
        guard let identifier = movieRepresentation.identifier,
        let hasWatched = movieRepresentation.hasWatched else { return nil }
        self.init(title: movieRepresentation.title, identifier: identifier, hasWatched: hasWatched)
    }
}
