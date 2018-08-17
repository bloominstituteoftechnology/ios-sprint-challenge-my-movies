//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Vuk Radosavljevic on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

protocol MovieCellHasBeenWatchedDelegate: class {
    func hasWathcedButtonTapped(on cell: MovieTableViewCell)
}

class MovieTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
    weak var delegate: MovieCellHasBeenWatchedDelegate?
    
    
    @IBAction func hasWatchedButtonPressed(_ sender: Any) {
        delegate?.hasWathcedButtonTapped(on: self)
    }
    
}
