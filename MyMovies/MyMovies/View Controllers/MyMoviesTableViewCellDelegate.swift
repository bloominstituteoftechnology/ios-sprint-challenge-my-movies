//
//  MyMoviesTableViewCellDelegate.swift
//  MyMovies
//
//  Created by John Pitts on 6/14/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

protocol MyMoviesTableViewCellDelegate {
    func toggleFeature(for cell: MyMoviesTableViewCell)
}
