//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Joshua Rutkowski on 2/23/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {
    //MARK: - IBOutlets
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieButton: UIButton!
    
    // MARK: - Properties
    
    var myMoviesController: MyMoviesController?
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    private func updateViews() {
        movieTitleLabel.text = movie?.title
        guard let watched = movie?.hasWatched else { return }
        switch watched {
        case true:
            movieButton.setTitle("Watched", for: .normal)
        case false: movieButton.setTitle("Not Watched", for: .normal)
        }
    }
    
    //MARK - IBActions
    @IBAction func movieWatchedTapped(_ sender: Any) {
        movie?.hasWatched.toggle()
        if let movie = movie {
            myMoviesController?.sendMyMovieToServer(movie: movie)
            switch movie.hasWatched {
            case true:
                movieButton.setTitle("Watched", for: .normal)
            case false: movieButton.setTitle("Not Watched", for: .normal)
            }
        }
    }
    
    
    
    
}
