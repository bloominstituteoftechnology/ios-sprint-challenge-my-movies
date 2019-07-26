//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Sean Acres on 7/26/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    var movie: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    var movieController: MovieController?
    
    @IBAction func addMovieTapped(_ sender: Any) {
        
    }
    
    func updateViews() {
        titleLabel.text = movie?.title
    }
}
