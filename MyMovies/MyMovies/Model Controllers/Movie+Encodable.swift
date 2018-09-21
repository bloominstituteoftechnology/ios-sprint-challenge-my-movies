//
//  Movie+Encodable.swift
//  MyMovies
//
//  Created by Moin Uddin on 9/21/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

extension Movie: Encodable {
    enum CodingKeys: String, CodingKey {
        case title
        case identifier
        case hasWatched
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = try encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.title, forKey: .title)
        try container.encode(self.identifier, forKey: .identifier)
        try container.encode(self.identifier, forKey: .identifier)
    }
}
