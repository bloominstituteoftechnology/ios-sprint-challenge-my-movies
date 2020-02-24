//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by David Wright on 2/23/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

protocol MovieSearchTableViewCellDelegate: class {
    func addMovieButtonTapped(sender: MovieSearchTableViewCell)
}

class MovieSearchTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    weak var delegate: MovieSearchTableViewCellDelegate?
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - IBActions
    
    @IBAction func addMovieButtonTapped(_ sender: UIButton) {
        delegate?.addMovieButtonTapped(sender: self)
    }
}

