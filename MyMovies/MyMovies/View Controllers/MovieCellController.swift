//
//  MovieCellController.swift
//  MyMovies
//
//  Created by Lotanna Igwe-Odunze on 11/9/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import UIKit

class MovieCell:UITableViewCell
{
    @IBOutlet weak var watchedButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    var movie:Movie! {
        didSet {
            nameLabel.text = movie.title!
            watchedButton.setTitle(
                movie.hasWatched ? "Watched": "Unwatched",
                for:.normal)
        }
    }
    
    @IBAction func toggleWatched(_ sender: Any)
    {
        MoviesManager.shared.watchToggle(movie)
        watchedButton.setTitle(
            movie.hasWatched ? "Watched": "Unwatched",
            for:.normal)
    }
}

class SearchCell:UITableViewCell
{
   
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    var movie: MovieRepresentation! {
        didSet {
            nameLabel.text = movie.title
            if MoviesManager.shared.existingMovie(title: movie.title) {
                saveButton.isEnabled = false
                saveButton.setTitle("", for:.normal)
            }
        }
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        MoviesManager.shared.newMovie(title: movie.title)
        saveButton.isEnabled = false
        saveButton.setTitle("", for:.normal)
    }
}
