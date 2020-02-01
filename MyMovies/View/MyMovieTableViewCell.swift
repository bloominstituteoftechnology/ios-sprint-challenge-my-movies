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
        guard let movie = movie else {
            print("movie is nil")
            return
        }
        movieTitleLabel.text = movie.title
        if movie.hasWatched {
            hasWatchedButton.setTitle("haven't watched", for: .normal)
            print("Have watched \(movie.title)")
        } else {
            hasWatchedButton.setTitle("have watched", for: .normal)
            print("Haven't watched \(movie.title)")
        }
    }

}
