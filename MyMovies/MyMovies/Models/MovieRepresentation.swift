//
//  MovieRepresentation.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

struct MovieRepresentation: Equatable, Codable {
    let title: String
    
    /*
     identifier and hasWatched are not a part of The Movie DB API, however they will be used both on Firebase and on the application itself.
     In order make the MovieRepresentation struct decode properly when fetching from the API, their types should stay optional.
     */
    
    let identifier: String?
    let watched: Bool?
}

func == (lhs: Movie, rhs: MovieRepresentation) -> Bool {
    return rhs.title == lhs.title &&
        rhs.identifier == lhs.identifier?.uuidString &&
        rhs.watched == lhs.watched
}
func == (lhs: MovieRepresentation, rhs: Movie) -> Bool {
    return rhs == lhs
}
func != (lhs: Movie, rhs: MovieRepresentation) -> Bool {
    return !(lhs == rhs)
}
func != (lhs: MovieRepresentation, rhs: Movie) -> Bool {
    return rhs != lhs
}

/*
 Represents the full JSON returned from searching for a movie.
 The actual movies are in the "results" dictionary of the JSON.
 */

struct MovieRepresentations: Codable {
    let results: [MovieRepresentation]
}

extension Movie: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(title, forKey: .title)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(watched, forKey: .watched)
    }
    
    enum CodingKeys: String, CodingKey {
        case title
        case identifier
        case watched
    }

}
