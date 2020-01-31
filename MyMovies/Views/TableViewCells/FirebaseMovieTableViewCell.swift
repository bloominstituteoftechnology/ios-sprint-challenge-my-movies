//
//  FirebaseMovieTableViewCell.swift
//  MyMovies
//
//  Created by Aaron Cleveland on 1/31/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class FirebaseMovieTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var buttonLabel: UIButton!
    
    var firebaseMovies: FirebaseMovies?
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    @IBAction func isWatchedTapped(_ sender: Any) {
        movie?.hasWatched.toggle()
        if let movie = movie {
            firebaseMovies?.sendFirebaseMovieToServer(movie: movie)
            
            switch movie.hasWatched {
            case true:
                buttonLabel.setTitle("Watched", for: .normal)
            case false:
                buttonLabel.setTitle("Not Watched", for: .normal)
            }
        }
    }
    
    func updateViews() {
        titleLabel.text = movie?.title
        guard let watched = movie?.hasWatched else { return }
        switch watched {
        case true:
            buttonLabel.setTitle("Watched", for: .normal)
        default:
            buttonLabel.setTitle("Not Watched", for: .normal)
        }
    }
}
