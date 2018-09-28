//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Scott Bennett on 9/28/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusButton: UIButton!
    
    var movieController: MovieController?
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    
    
    func updateViews() {
        guard let movie = movie else { return }
        
        titleLabel.text = movie.title
        if movie.hasWatched {
            statusButton.setTitle("Watched", for: .normal)
        } else {
            statusButton.setTitle("UnWatched", for: .normal)
        }
        
    }
    

    @IBAction func statusLabel(_ sender: Any) {
        
        guard let movie = movie else { return }
        movie.hasWatched.toggle()
        movieController?.update(movie: movie, hasWatched: movie.hasWatched)
    }
    
}
