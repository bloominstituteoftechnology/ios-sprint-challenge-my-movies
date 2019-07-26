//
//  MovieTableViewCellDelegate.swift
//  MyMovies
//
//  Created by Nathan Hedgeman on 7/26/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

protocol MovieTableViewCellDelegate: class {
    func toggleHasBeenSeen(for cell: MyMoviesTableViewCell)
}
