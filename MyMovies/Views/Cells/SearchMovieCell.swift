//
//  SearchMovieCell.swift
//  MyMovies
//
//  Created by scott harris on 2/28/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class SearchMovieCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    var delegate: SearchMovieCellDelegate?
    
    @IBAction func addMovieTapped(_ sender: Any) {
        delegate?.addMovie(for: self)
    }
}
