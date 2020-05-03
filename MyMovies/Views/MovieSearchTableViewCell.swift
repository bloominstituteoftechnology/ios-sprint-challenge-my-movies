//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by patelpra on 5/3/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {

    @IBOutlet weak var movieSearchTitle: UILabel!
    
    weak var delegate: MovieSearchTableViewCellDelegate?

    @IBAction func saveMovieToMyMovies(_ sender: Any) {
        delegate?.saveMovieToMyMovies(for: self)
        
    }
}
