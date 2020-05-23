//
//  Protocol.swift
//  MyMovies
//
//  Created by Stephanie Ballard on 5/22/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

protocol MyMoviesTableViewDelegate: AnyObject {
    func toggleHasBeenWatchedButton(cell: MovieTableViewCell)
}

