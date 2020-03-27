//
//  Movie+convenience.swift
//  MyMovies
//
//  Created by Lambda_School_Loaner_259 on 3/27/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    
    var movieRepresentation: MovieRepresentation? {
        guard let title = title else { return nil }
        
        return MovieRepresentation(title: title,
                                   identifier: identifier,
                                   hasWatched: hasWatched)
    }
    
    @discardableResult convenience init(title: String,
                                        identifier: UUID = UUID(),
                                        hasWatched: Bool?,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.identifier = identifier
        self.title = title
        self.bodyText = bodyText
        self.timestamp = Date()
        self.mood = mood
    }
    
    @discardableResult convenience init?(entryRepresentation: EntryRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard let identifierString = entryRepresentation.identifier,
            let identifier = UUID(uuidString: identifierString),
            let mood = Mood(rawValue: entryRepresentation.mood ?? Mood.neutral.rawValue) else { return nil }
        
        self.init(identifier: identifier,
                  title: entryRepresentation.title,
                  bodyText: entryRepresentation.bodyText,
                  timestamp: entryRepresentation.timestamp,
                  mood: mood.rawValue,
                  context: context)
    }
}


