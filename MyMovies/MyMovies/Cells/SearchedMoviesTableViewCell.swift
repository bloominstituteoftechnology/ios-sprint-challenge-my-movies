//
//  SearchedMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Vuk Radosavljevic on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

protocol MovieTableViewCellDelegate: class {
    func addMovieButtonWasTapped(on cell: SearchedMoviesTableViewCell)
}

class SearchedMoviesTableViewCell: UITableViewCell {

    // MARK: - Properties
    weak var delegate: MovieTableViewCellDelegate?
    
    
    
    
    // MARK: - Methods
    @IBAction func addMovie(_ sender: Any) {
        delegate?.addMovieButtonWasTapped(on: self)
    }
    
    @IBOutlet weak var titleLabel: UILabel!
}
