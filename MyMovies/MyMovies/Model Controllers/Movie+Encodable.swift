//
//  Movie+Encodable.swift
//  MyMovies
//
//  Created by Yvette Zhukovsky on 11/9/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//


import Foundation
import CoreData

enum CodingKeys: String, CodingKey {
    
    case title
    case hasWatched
    case identifier  
}

extension Movie: Encodable {
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(title, forKey: .title)
        try container.encode(hasWatched, forKey: .hasWatched)
        try container.encode(identifier, forKey: .identifier)
        
        
    }
}

