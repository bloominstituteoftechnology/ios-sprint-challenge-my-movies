//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Kenny on 1/31/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MyMovieTableViewCell: UITableViewCell {
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    @IBAction func hasWatchedButtonTapped(_ sender: UIButton) {
        guard let movie = movie,
            let title = movie.title
        else {return}
        
        movie.hasWatched = !movie.hasWatched
        let rep = movie.movieRepresentation ?? MovieRepresentation(title: title, identifier: movie.identifier, hasWatched: movie.hasWatched)
        movieController?.updateMovie(movie: movie, movieRep: rep)
    }
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    var movieController: MovieController?
    
    func updateViews() {
        guard let movie = movie else {return}
        if movie.hasWatched {
            movieTitleLabel.text = movie.title
            hasWatchedButton.setTitle("watch", for: .normal)
        } else {
            hasWatchedButton.setTitle("watched", for: .normal)
            movieTitleLabel.text = movie.title
        }
    }

}
