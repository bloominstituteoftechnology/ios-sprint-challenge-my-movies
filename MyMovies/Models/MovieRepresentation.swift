 //
//  MovieRepresentation.swift
//  MyMovies
//
//  Created by Clayton Watkins on 6/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

 struct MovieRepresentation: Equatable, Codable{
    var title: String
    var identifier: UUID?
    var hasWatched: Bool?
 }
