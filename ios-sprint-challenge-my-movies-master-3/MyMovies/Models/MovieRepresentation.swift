//
//  MovieRepresentation.swift
//  MyMovies
//
//  Created by Dahna on 5/22/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

struct MovieRepresentation: Codable {
    var title: String
    var identifier: UUID?
    var hasWatched: Bool?
}
