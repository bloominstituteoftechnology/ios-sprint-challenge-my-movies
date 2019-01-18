//
//  MovieCell.swift
//  MyMovies
//
//  Created by Lotanna Igwe-Odunze on 1/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import UIKit

class MovieCellController: UITableViewCell {
    
    @IBOutlet weak var myMovieLabel: UILabel!
    @IBOutlet weak var statusButton: UIButton!
    
    var movie: Movie! {
        didSet {
            myMovieLabel.text = movie.title!
            statusButton.setTitle(
                movie.hasWatched ? "Watched": "Unwatched",
                for:.normal )
        }
    }
    
    @IBAction func toggledWatchStatus(_ sender: UIButton) { CoreDataController().watchToggle(movie)
        statusButton.setTitle(
            movie.hasWatched ? "Watched": "Unwatched",
            for:.normal) }
    
}
