//
//  Keys.swift
//  MyMovies
//
//  Created by Chris Gonzales on 2/28/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

struct Keys {
    static let persistenceContainer = "MyMovies"
    static let movieCellString = "MovieCell"
    static let movieListCellString = "MovieTableViewCell"
}

enum HTTPMethods: String {
    case put = "PUT"
    case delete = "DELETE"
}
