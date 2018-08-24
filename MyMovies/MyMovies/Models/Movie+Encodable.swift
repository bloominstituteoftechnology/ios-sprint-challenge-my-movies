//
//  Movie+Encodable.swift
//  MyMovies
//
//  Created by Lisa Sampson on 8/24/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie: Encodable {
    
    enum CodingKeys: String, CodingKey {
        case title
        case hasWatched
        case identifier
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(title, forKey: .title)
        try container.encode(hasWatched, forKey: .hasWatched)
        try container.encode(identifier, forKey: .identifier)
    }
}
