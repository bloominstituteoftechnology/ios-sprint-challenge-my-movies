//
//  MovieProtocol.swift
//  MyMovies
//
//  Created by Kobe McKee on 6/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

protocol MovieProtocol: class {
    var movieController: MovieController? { get set }
}
