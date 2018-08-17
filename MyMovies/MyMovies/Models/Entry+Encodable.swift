//
//  Entry+Encodable.swift
//  Journal (Core Data)
//
//  Created by Simon Elhoej Steinmejer on 15/08/18.
//  Copyright © 2018 Simon Elhoej Steinmejer. All rights reserved.
//

import Foundation

extension Movie: Encodable
{
    enum CodingKeys: String, CodingKey
    {
        case title = "title"
        case hasWatched = "hasWatched"
        case identifier = "identifier"
    }
    
    public func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(hasWatched, forKey: .hasWatched)
        try container.encode(identifier, forKey: .identifier)
    }
}
