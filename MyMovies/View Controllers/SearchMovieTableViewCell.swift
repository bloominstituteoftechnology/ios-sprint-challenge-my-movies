//
//  SearchMovieTableViewCell.swift
//  MyMovies
//
//  Created by Nathan Hedgeman on 8/25/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class SearchMovieTableViewCell: UITableViewCell {
    //Properties
    @IBOutlet weak var titleLabel: UILabel!
    var delegate: SearchMovieTableViewCellDelegate?
    @IBAction func addMovieToCoreDataButtonTapped(_ sender: Any) {
        delegate?.addMovieToCoreData(for: self)
    }
}
