//
//  SearchCell.swift
//  MyMovies
//
//  Created by Lotanna Igwe-Odunze on 1/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import UIKit

class SearchCellController: UITableViewCell {
    
    @IBOutlet weak var searchedMovieLabel: UILabel!
    @IBOutlet weak var saveMovieButton: UIButton!
    @IBAction func clickedSaveButton(_ sender: UIButton) {
        CoreDataController().newMovie(title: movie.title)
        saveMovieButton.isEnabled = false
        saveMovieButton.setTitle("", for:.normal)
    }

    
    var movie: MovieRepresentation! {
        didSet {
                searchedMovieLabel.text = movie?.title
                if CoreDataController().existingMovie(title: movie.title) {
                saveMovieButton.isEnabled = false
                saveMovieButton.setTitle("", for:.normal)
            }
        }
    }
    
    
}

