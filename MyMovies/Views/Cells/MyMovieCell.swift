//
//  MyMovieCell.swift
//  MyMovies
//
//  Created by scott harris on 2/28/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MyMovieCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    var delegate: MyMovieCellDelegate?
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    
    @IBAction func hasWatchedTapped(_ sender: Any) {
//        if let movie = movie {
//            movie.hasWatched.toggle()
//            configureButton(movie: movie)
//        }
        delegate?.updateHasWatched(for: self)
        
    }
    
    private func updateViews() {
        if let movie = movie {
            titleLabel.text = movie.title
            configureButton(movie: movie)
            
        }
    }
    
    private func configureButton(movie: Movie) {
        if movie.hasWatched {
            hasWatchedButton.setTitle("Watched", for: .normal)
        } else {
            hasWatchedButton.setTitle("Unwatched", for: .normal)
        }
    }
    
}
