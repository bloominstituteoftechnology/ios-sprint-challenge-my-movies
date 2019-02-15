//
//  Movie+Encodable.swift
//  MyMovies
//
//  Created by Nelson Gonzalez on 2/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

extension Movie: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(hasWatched, forKey: .hasWatched)
        try container.encode(title, forKey: .title)
    }
    
    enum CodingKeys: String, CodingKey {
        case title
        case identifier
        case hasWatched
    }
    
}
