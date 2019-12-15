//
//  SearchTableViewCell.swift
//  MyMovies
//
//  Created by denis cedeno on 12/14/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var movieTitleLabel: UILabel!
    
    @IBOutlet weak var addMovieButton: UIButton!
    
    var movieRepresenation: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        guard let movieRep = movieRepresenation else { return }
        movieTitleLabel.text = movieRep.title
    }
}
