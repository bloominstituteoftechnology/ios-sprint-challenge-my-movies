//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Juan M Mariscal on 5/1/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

enum SeenPriority: String, CaseIterable {
    case watched
    case unwatched
}

extension Movie {
    
    @discardableResult convenience init(identifier: UUID = UUID(),
                                        title: String,
                                        hasWatched: Bool = false,
                                        priority: SeenPriority = .unwatched,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.identifier = identifier
        self.title = title
        self.hasWatched = hasWatched
        self.priority = priority.rawValue
    }
    
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation,
                                         context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        guard let priority = SeenPriority(rawValue: movieRepresentation.priority!),
            let identifier = UUID(uuidString: movieRepresentation.identifier!),
            let hasWatched = movieRepresentation.hasWatched else {
                return nil
        }
        
        self.init(identifier: identifier,
              title: movieRepresentation.title,
              hasWatched: hasWatched,
              priority: priority,
              context: context)
    }
    
    var movieRepresentation: MovieRepresentation? {
        guard let title = title else { return nil }
        
        let id = identifier ?? UUID()
        
        return MovieRepresentation(title: title,
                                   identifier: id.uuidString,
                                   hasWatched: hasWatched,
                                   priority: priority)
    }
    
}
