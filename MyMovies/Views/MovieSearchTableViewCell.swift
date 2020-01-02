//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Joe Thunder on 12/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {

    @IBOutlet weak var addMovieButton: UIButton!
    
    let movieController = MovieController()
    
    
    
    @IBAction func addMovieButtonTapped(_ sender: Any) {
        movieController.save()
    }
    
    
}
