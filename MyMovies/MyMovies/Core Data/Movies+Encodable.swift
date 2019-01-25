//
//  Movies+Encodable.swift
//  MyMovies
//
//  Created by jkaunert on 1/25/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie: Encodable {
    enum CodingKeys: String, CodingKey {
        case title
        case identifier
        case hasWatched
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.title, forKey: .title)
        try container.encode(self.identifier, forKey: .identifier)
        try container.encode(self.hasWatched, forKey: .hasWatched)
    }
    
}
