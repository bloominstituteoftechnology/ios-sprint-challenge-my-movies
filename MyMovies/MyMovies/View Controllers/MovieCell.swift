//
//  MovieCell.swift
//  MyMovies
//
//  Created by Victor  on 5/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import UIKit

//MyMovie
class MovieCell: UITableViewCell {
    //Outlets
    @IBOutlet weak var movieLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    
    //Properties
    var movieController : MovieController?
    var movie: Movie?{
        didSet {
            updateViews()
        }
    }
    
    private func updateViews(){
        //checking for movie object and updating labels
        guard let movie = movie else {return}
        movieLabel.text = movie.title

        //updating button
        if movie.hasWatched {
            hasWatchedButton.setTitle("Watched", for: .normal)
        } else {
            hasWatchedButton.setTitle("Unwatched", for: .normal)
        }
    }
    
}
