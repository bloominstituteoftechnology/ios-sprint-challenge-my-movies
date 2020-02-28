//
//  MyMovieCellDelegate.swift
//  MyMovies
//
//  Created by scott harris on 2/28/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

protocol MyMovieCellDelegate {
    func updateHasWatched(for cell: MyMovieCell)
}
