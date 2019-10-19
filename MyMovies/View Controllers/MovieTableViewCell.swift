//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by brian vilchez on 10/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    //MARK: - properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hasBeenWatched: UIButton!
    var movieController = MovieController()
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
@IBAction func watchButton(_ sender: UIButton) {
    guard let movie = movie else {return}
    if hasBeenWatched.titleLabel?.text == "unwatched" {
        movieController.updateMovie(movie)
        hasBeenWatched.setTitle("watched", for: .normal)
        print(movie.hasWatched)
    } else {
        movieController.updateMovie(movie)
        hasBeenWatched.setTitle("unwatched", for: .normal)
        print(movie.hasWatched)
    }
    }
    
 private func updateViews() {
        guard let movie = movie else {return}
        titleLabel.text = movie.title
    hasBeenWatched.setTitle("unwatched", for: .normal)
    }
}
