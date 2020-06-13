//
//  MovieRepresentation.swift
//  MyMovies
//
//  Created by Bohdan Tkachenko on 6/13/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

struct MovieRepresentation: Codable, Equatable {
    var title: String
    var identifier: UUID?
    var hasWatched: Bool?
    
}
