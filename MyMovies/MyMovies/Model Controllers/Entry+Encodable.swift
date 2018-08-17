//
//  Entry+Encodable.swift
//  MyMovies
//
//  Created by Vuk Radosavljevic on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

extension Entry: Encodable {
    
    
    enum CodingKeys: String, CodingKey {
        case title
        case identifier
        case hasWatched
    }
    
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(hasWatched, forKey: .hasWatched)
        try container.encode(identifier, forKey: .identifier)
    }
    
    
    
}
