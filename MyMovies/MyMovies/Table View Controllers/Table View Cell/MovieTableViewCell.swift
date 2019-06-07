//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Michael Flowers on 6/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    var movie: Movie? {
        didSet {
            print("MovieTableViewCell: movie was set")
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var watchedProperties: UIButton!
    
    @IBAction func changeWatchedButton(_ sender: UIButton) {
         guard let passedInMovie = movie else { print("Error passing in movie in movietableviewcell"); return }
        MyMovieController.shared.toggle(movie: passedInMovie)
        let buttonTitle = passedInMovie.hasWatched ? "Watched" : "UnWatched"
        watchedProperties.setTitle(buttonTitle, for: .normal)
    }
    
    private func updateViews(){
        guard let passedInMovie = movie else { print("Error passing in movie in movietableviewcell"); return }
        nameLabel.text = passedInMovie.title
        let buttonTitle = passedInMovie.hasWatched ? "Watched" : "UnWatched"
        watchedProperties.setTitle(buttonTitle, for: .normal)
    }
}
