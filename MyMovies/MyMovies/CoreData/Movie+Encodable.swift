//
//  Movie+Encodable.swift
//  MyMovies
//
//  Created by Sergey Osipyan on 1/25/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

extension Movies: Encodable  {
    
    enum CodingKeys: String, CodingKey {
        
        case hasWatched
        case identifier
        case timestamp
        case title   
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        do {
            try container.encode(title, forKey: .title)
            try container.encode(timestamp, forKey: .timestamp)
            try container.encode(identifier, forKey: .identifier)
            try container.encode(hasWatched, forKey: .hasWatched)
            
        } catch {
            print("could not encode keys")
        }
    }
}
