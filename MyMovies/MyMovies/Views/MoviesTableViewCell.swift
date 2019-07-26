//
//  MoviesTableViewCell.swift
//  MyMovies
//
//  Created by Kat Milton on 7/26/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MoviesTableViewCell: UITableViewCell {
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    var movieController: MovieController?
    

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var watchedButton: UIButton!
    
    
    @IBAction func movieWatchedPressed(_ sender: UIButton) {
        guard let movie = movie else { return }
        
        movie.hasWatched.toggle()
        movieController?.updateMovie(movie: movie, hasWatched: movie.hasWatched)
        
        if movie.hasWatched == true {
            sender.setTitle("Watched", for: .normal)
        } else {
            sender.setTitle("Unwatched", for: .normal)
        }
    }
    
    func updateViews() {
        
        if let movie = movie {
            titleLabel.text = movie.title
            if movie.hasWatched == true {
                watchedButton.titleLabel?.text = "Watched"
            } else {
                watchedButton.titleLabel?.text = "Unwatched"
            }
        }
    }

}
