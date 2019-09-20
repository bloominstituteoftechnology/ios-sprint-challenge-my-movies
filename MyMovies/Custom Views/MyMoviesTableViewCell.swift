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
      titleLabel.text = movie?.title
         hasWatchedButton.setTitle("UNSEEN", for: .normal)
        
    }
    
    @IBAction func hasWatchedButtonTapped(_ sender: UIButton) {
        
        guard let movie = movie else {return}
       
        if movie.hasWatched {
            movieController?.updateMovie(movie: movie, hasWatched: true)
            hasWatchedButton.setTitle("UNSEEN", for: .normal)
        } else {
            movieController?.updateMovie(movie: movie, hasWatched: false)
            hasWatchedButton.setTitle("SEEN", for: .normal)

        }
    }
}
