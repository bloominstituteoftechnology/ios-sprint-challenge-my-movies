//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Aaron Cleveland on 1/31/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var firebaseMovie: FirebaseMovies?
    var movie: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    @IBAction func isWatchedButtonTapped(_ sender: Any) {
        guard let movie = movie else { return }
        
        let newMov = Movie(title: movie.title)
        firebaseMovie?.sendFirebaseMovieToServer(movie: newMov)
    }
    
    func updateViews() {
        titleLabel.text = movie?.title
    }
}
