//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by brian vilchez on 9/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    let movieController = MovieController()
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }

    private func updateViews() {
        guard let movie = movie else {return}
        titleLabel.text = movie.title
    }
    
    
    @IBAction func hasWatchedButton(_ sender: UIButton) {
        guard let movie = movie else {return}
        if hasWatchedButton.titleLabel?.text == "unwatched" {
            movieController.updateHasBeenWatched(forMovie: movie)
            hasWatchedButton.setTitle("watched", for: .normal)
            print(movie.hasWatched)
        } else {
            movieController.updateHasBeenWatched(forMovie: movie)
            hasWatchedButton.setTitle("unwatched", for: .normal)
            print(movie.hasWatched)
        }
    }
}
