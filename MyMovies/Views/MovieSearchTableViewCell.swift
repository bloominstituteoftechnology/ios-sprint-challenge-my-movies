//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Wyatt Harrell on 3/27/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addMovieButton: UIButton!
    
    var movieRepresentation: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    @IBAction func addMovieButtonTapped(_ sender: Any) {
    }
    
    
    func updateViews() {
        guard let movieRepresentation = movieRepresentation else { return }
        
        titleLabel.text = movieRepresentation.title
        
    }
}
