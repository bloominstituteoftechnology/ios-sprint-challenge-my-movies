//
//  MovieRepresentation.swift
//  MyMovies
//
//  Created by Cody Morley on 5/22/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

struct MovieRepresentation: Codable {
    enum CodingKeys: String, CodingKey {
        case identifier
        case title
        case hasWatched
    }
    
    let identifier: String
    let title: String
    let hasWatched: Bool
}
