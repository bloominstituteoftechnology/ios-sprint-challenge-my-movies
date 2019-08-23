//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Jake Connerly on 8/23/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {
    
    let movieController = MovieController()

    // MARK: - IBOutlets & Properties
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    
    // MARK: - IBActions & Methods
    
    @IBAction func addMovieButtonTapped(_ sender: UIButton) {
        guard let title = movieTitleLabel.text else { return }
        movieController.createMovie(with: title, hasWatched: false)
    }
}
