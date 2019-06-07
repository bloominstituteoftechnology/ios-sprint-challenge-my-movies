//
//  MoviesProtocol.swift
//  MyMovies
//
//  Created by Mitchell Budge on 6/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

protocol MovieProtocol: class {
    var movieController: MovieController? { get set }
}
