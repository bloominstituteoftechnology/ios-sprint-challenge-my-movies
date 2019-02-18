//
//  Movie+Encodable.swift
//  MyMovies
//
//  Created by Lambda_School_Loaner_34 on 2/17/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

extension Movie: Encodable {
    
    enum CodingKeys: String, CodingKey {
        case title
        case identifier
        case hasWatched
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(identifier, forKey: .identifier)
        try container.encodeIfPresent(hasWatched, forKey: .hasWatched)
    }
}
