//
//  MyMoviesCellDelegate.swift
//  MyMovies
//
//  Created by Carolyn Lea on 8/25/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

protocol MyMoviesCellDelegate: class
{
    func toggleWatchedMovie(cell: MyMoviesCell)
}
