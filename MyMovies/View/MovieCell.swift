//
//  MovieCell.swift
//  MyMovies
//
//  Created by Nick Nguyen on 2/28/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {
    
    var movie: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    private func updateViews() {
        if let movie = movie {
            movieTitle.text = movie.title
        }
    }
    
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var movieTitle: UILabel!
    
    
    
    
    
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        print("Hello")
    }
    
    
}

