//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Mark Gerrior on 3/27/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {

    // MARK: - Properities
    var movieController: MovieController?
    
    // MARK: - Outlets
    
    // MARK: - Actions
    
    @IBAction func addMovieButton(_ sender: Any) {
        guard let title = self.textLabel?.text else { return }

        movieController?.create(title: title)
    }
}
