//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Sergey Osipyan on 1/25/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movies {
    
    
    convenience init(title: String, identifier: UUID = UUID(), hasWatched: Bool, timestamp: Date = Date(), context: NSManagedObjectContext) {
        
        self.init(context: context)
        
        self.title = title
        self.identifier = identifier
        self.timestamp = timestamp
        self.hasWatched = hasWatched
        
        
    }
    convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext) {
        
            let title = movieRepresentation.title
            let timestamp = Date()
           guard let hasWatched = movieRepresentation.hasWatched,
            let identifier = movieRepresentation.identifier
        
             else { return nil}
        
        self.init(title: title, identifier: identifier, hasWatched: hasWatched, timestamp: timestamp, context: context)
    }
    
    var timeFormatted: String? {
        guard let timestamp = timestamp else {
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let timeAndDate = dateFormatter.string(from: timestamp)
        return timeAndDate
        
    }
    
}

