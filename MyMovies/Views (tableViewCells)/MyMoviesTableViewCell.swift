//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Shawn James on 4/24/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {

    var movieController: MovieController?
    
    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var isWatchedButton: UIButton!

    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    @IBAction func isWatchedButtonTapped(_ sender: UIButton) {
        guard let movie = movie else { return }
        
        // FIXME: - toggle hasWatched
        
        movieController?.update(movie: movie, with: MovieRepresentations)
        
        
        updateViews()
    }
    
    func updateViews() {
        guard let movie = self.movie else { return }
        movieNameLabel.text = movie.title
        isWatchedButton.setTitle((movie.hasWatched == true ? "Watched" : "Not Watched"), for: .normal)
    }

}
