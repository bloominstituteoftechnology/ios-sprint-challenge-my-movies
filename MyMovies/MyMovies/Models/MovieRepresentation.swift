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
    
    let identifier: UUID?
    let hasWatched: Bool?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let title = try container.decode(String.self, forKey: .title)
        let identifier = try container.decodeIfPresent(String.self, forKey: .identifier)
        let hasWatched = try container.decodeIfPresent(Bool.self, forKey: .hasWatched)

        self.title = title
        if let identifier = identifier, let hasWatched = hasWatched {
            self.identifier = UUID(uuidString: identifier)
            self.hasWatched = hasWatched
        } else {
            self.identifier = nil
            self.hasWatched = nil
        }
    }
    
}

/*
 Represents the full JSON returned from searching for a movie.
 The actual movies are in the "results" dictionary of the JSON.
 */
struct MovieRepresentations: Codable {
    let results: [MovieRepresentation]
}

func ==(lhs: MovieRepresentation, rhs: Movie) -> Bool {
    return lhs.title == rhs.title &&
           lhs.hasWatched == rhs.hasWatched &&
           lhs.identifier == rhs.identifier
}

func ==(lhs: Movie, rhs: MovieRepresentation) -> Bool {
    return rhs == lhs
}

func !=(lhs: MovieRepresentation, rhs: Movie) -> Bool {
    return !(rhs == lhs)
}

func !=(lhs: Movie, rhs: MovieRepresentation) -> Bool {
    return rhs != lhs
}
