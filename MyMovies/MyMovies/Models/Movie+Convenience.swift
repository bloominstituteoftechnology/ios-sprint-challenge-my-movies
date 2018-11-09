//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Nikita Thomas on 11/9/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    convenience init(title: String,
                     hasWatched: Bool,
                     identifier: UUID = UUID(),
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.title = title
        self.hasWatched = hasWatched
        self.identifier = identifier
    }
}

extension Movie: Encodable {
    enum CodingKeys: String, CodingKey {
        case title, hasWatched, identifier
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: CodingKeys.title)
        try container.encode(hasWatched, forKey: CodingKeys.hasWatched)
        try container.encode(identifier, forKey: CodingKeys.identifier)
    }
}
