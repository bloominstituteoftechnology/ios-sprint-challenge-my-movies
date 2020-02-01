//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Kenny on 1/31/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MyMovieTableViewCell: UITableViewCell {
    
    //MARK: IBOutlets
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    //MARK: IBActions
    @IBAction func hasWatchedButtonTapped(_ sender: UIButton) {
        guard let movie = movie,
            let title = movie.title
        else {return}
        movie.hasWatched = !movie.hasWatched
        let rep = movie.movieRepresentation ?? MovieRepresentation(title: title, identifier: movie.identifier, hasWatched: movie.hasWatched)
        movieController?.updateMovie(movie: movie, movieRep: rep)
    }
    
    //MARK: Properties
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    var movieController: MovieController?
    
    //MARK: Methods
    func updateViews() {
        hasWatchedButton.titleEdgeInsets = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        hasWatchedButton.layer.borderColor = UIColor.systemBlue.cgColor
        hasWatchedButton.layer.borderWidth = 2
        guard let movie = movie else {return}
        movieTitleLabel.text = movie.title
        if movie.hasWatched {
            hasWatchedButton.setTitle(" Haven't watched ", for: .normal)
        } else {
            hasWatchedButton.setTitle(" Have watched ", for: .normal)
        }
    }

}
