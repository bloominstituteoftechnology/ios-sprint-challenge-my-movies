//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Hayden Hastings on 6/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMovieTableViewCell: UITableViewCell {
    
    var movieController: MovieController?
    var movieRep: MovieRepresentation?

    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
   
    private func updateViews() {
        guard let movie = movie else { return }
        titleLabel.text = movie.title
        if movie.hasWatched == true {
            hasWatchedButton.setTitle("Watched", for: .normal)
        } else {
            hasWatchedButton.setTitle("Unwatched", for: .normal)
        }
    }
    
    @IBAction func hasWatchedButtonPressed(_ sender: Any) {
        guard let movie = movie else { return }
        movie.hasWatched = !movie.hasWatched
        movieController?.updateMovie(movie: movie)
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
}
