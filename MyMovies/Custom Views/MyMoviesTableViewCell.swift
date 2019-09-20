//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Alex Rhodes on 9/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var hasWatchedButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    var movieController: MovieController?
    
    var movie: Movie? {
        didSet {
            setViews()
        }
    }
    
    private func setViews() {
        guard let movie = movie else {return}
        titleLabel.text = movie.title
        
        if movie.hasWatched == false {
            hasWatchedButton.setTitle("Unwatched", for: .normal)
        } else if movie.hasWatched == true {
            hasWatchedButton.setTitle("Watched", for: .normal)
            
        }
    }
    
    @IBAction func hasWatchedButtonTapped(_ sender: UIButton) {
        
        guard let movie = movie else {return}
        
        if movie.hasWatched == false {
            movieController?.updateMovie(movie: movie, hasWatched: true)
            hasWatchedButton.setTitle("Watched", for: .normal)
        } else if movie.hasWatched == true {
            movieController?.updateMovie(movie: movie, hasWatched: false)
            hasWatchedButton.setTitle("Unwatched", for: .normal)
            
        }
    }
}
