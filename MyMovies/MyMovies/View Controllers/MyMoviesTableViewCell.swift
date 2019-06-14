//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Thomas Cacciatore on 6/14/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {

    private func updateViews() {
        guard let movie = movie else { return }
        titleLabel.text = movie.title
        if movie.hasWatched {
            hasWatchedButton.setTitle("Watched", for: .normal
            )
        } else {
            hasWatchedButton.setTitle("Unwatched", for: .normal)
        }
    }

    @IBAction func hasWatchedButtonTapped(_ sender: Any) {
        //update the button title
        if let updatedMovie = movie {
            updatedMovie.hasWatched.toggle()
            
            movieController.put(movie: updatedMovie)
            
        }
        //toggle hasWatched bool for movie
        //put to FB and save updates to local
    }
    
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    var movieController = MovieController()
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
}
