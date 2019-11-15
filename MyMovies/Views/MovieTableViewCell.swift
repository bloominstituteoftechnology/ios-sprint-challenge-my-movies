//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by brian vilchez on 11/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

//MARK: - properties
@IBOutlet weak var hasBeenWatched: UIButton!
var movieController = MovieController()
var movie: Movie? {
    didSet {
        updateViews()
    }
}
        
@IBAction func watchButton(_ sender: UIButton) {
    guard let movie = movie else {return}
    hasBeenWatched.isSelected = !hasBeenWatched.isSelected
    if hasBeenWatched.isSelected {
        hasBeenWatched.setTitle("watched", for: .normal)
        movieController.updateMovie(movie)
        print(movie.hasBeenWatched)
    } else {
        hasBeenWatched.setTitle("unwatched", for: .normal)
        movieController.updateMovie(movie)
        print(movie.hasBeenWatched)
        }
    }
        
private func updateViews() {
    guard let movie = movie else {return}
    self.textLabel?.text = movie.title
    }

}
