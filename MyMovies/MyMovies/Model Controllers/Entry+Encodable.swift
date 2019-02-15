//
//  Entry+Encodable.swift
//  MyMovies
//
//  Created by Jocelyn Stuart on 2/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

extension Movie: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(title, forKey: .title)
        //try container.encodeIfPresent(bodyText, forKey: .bodyText)
        try container.encode(hasWatched, forKey: .hasWatched)
        try container.encode(identifier, forKey: .identifier)
    }
    
    enum CodingKeys: String, CodingKey {
        
        case title
        case identifier
        case hasWatched
        
    }
}
