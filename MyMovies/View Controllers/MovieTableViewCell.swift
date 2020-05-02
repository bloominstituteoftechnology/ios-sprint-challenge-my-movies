//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Kevin Stewart on 5/1/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    
    var movieController: MovieController?
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Outlets
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var watchedButton: UIButton!
    
    // MARK: - Actions
    @IBAction func toggleWatched(_ sender: UIButton) {
        movie?.hasWatched.toggle()
        guard let updatedMovie = movie else { return }
        movieController?.putMoviesToServer(movie: updatedMovie)
        updateViews()
    }

    func updateViews() {
        guard let movie = movie else { return }
        titleLabel.text = movie.title
        
        if movie.hasWatched == false {
            watchedButton.setTitle("Unwatched", for: .normal)
        } else {
            watchedButton.setTitle("Watched", for: .normal)
        }
        
    }
    
}
