//
//  MovieRepresentation.swift
//  MyMovies
//
//  Created by Sammy Alvarado on 8/16/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

struct MovieRepresentation: Codable {
    var hasWatched: Bool
    var identifier: String?
    var title: String 
}
