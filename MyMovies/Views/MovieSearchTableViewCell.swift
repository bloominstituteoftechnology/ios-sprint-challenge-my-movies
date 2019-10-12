//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by John Kouris on 10/12/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    
    var movieController = MovieController()

    @IBAction func addMovieButtonTapped(_ sender: Any) {
        guard let title = movieTitleLabel.text else { return }
        let movie = Movie(title: title)
        movieController.put(movie: movie)
    }
    
}
