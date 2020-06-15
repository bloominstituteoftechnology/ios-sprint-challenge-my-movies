//
//  MovieRepresentation.swift
//  MyMovies
//
//  Created by Sammy Alvarado on 6/14/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

struct MovieRepresentation: Codable {
    var identifier: String
    var title: String
    var hasWatched: Bool
}
