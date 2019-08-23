//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Bradley Yin on 8/23/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMovieTableViewCell: UITableViewCell {
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    var movieController: MovieController!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    func updateViews() {
        guard let movie = movie else { return }
        titleLabel.text = movie.title
        if movie.hasWatched {
            hasWatchedButton.setTitle("watched", for: .normal)
        } else {
            hasWatchedButton.setTitle("not watched", for: .normal)
        }
    }
    @IBAction func hasWatchedTapped(_ sender: Any) {
        guard let movie = movie else { return }
        movieController.updateHasWatched(movie: movie)
        updateViews()
    }
    
    

}
