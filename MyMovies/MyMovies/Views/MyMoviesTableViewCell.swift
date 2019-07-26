//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Sean Acres on 7/26/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {

    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    var movieController: MovieController?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    @IBAction func hasWatchedTapped(_ sender: Any) {
        guard let movie = movie,
            let movieController = movieController else { return }
        
        movie.hasWatched.toggle()
        movieController.updateMovie(movie: movie, hasWatched: movie.hasWatched)
        
        updateViews()
    }
    
    func updateViews() {
        guard let movie = movie else { return }
        
        titleLabel.text = movie.title
        if movie.hasWatched {
            hasWatchedButton.setTitle("Watched", for: .normal)
        } else {
            hasWatchedButton.setTitle("Unwatched", for: .normal)
        }
        
    }
}
