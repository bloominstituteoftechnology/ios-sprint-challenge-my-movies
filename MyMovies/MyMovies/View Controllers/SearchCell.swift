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
    
    var movie: MovieRepresentation! {
        didSet {
            searchedMovieLabel.text = movie?.title
            if CoreDataController.shared.movieExistsLocally(title: movie.title) == true {
                saveMovieButton.isEnabled = false
                saveMovieButton.setTitle("Already Saved", for:.normal)
            }
        }
    }
    
    override func prepareForReuse() {
        saveMovieButton.isEnabled = true
        saveMovieButton.setTitle("Save", for: .normal)
    }
    
    @IBAction func clickedSaveButton(_ sender: UIButton) {
        CoreDataController.shared.newMovie(title: movie.title)
        saveMovieButton.isEnabled = false
        saveMovieButton.setTitle("Saved", for:.normal)
    }

    
}

