//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Enrique Gongora on 2/28/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

protocol MovieSearchTableViewCellDelegate: class {
    func addMovieButtonTapped(sender: MovieSearchTableViewCell)
}

class MovieSearchTableViewCell: UITableViewCell {
    
    //MARK: - Variables
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    weak var delegate: MovieSearchTableViewCellDelegate?
    
    //MARK: - IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    
    //MARK: - IBAction
    @IBAction func addMovieButton(_ sender: UIButton) {
        delegate?.addMovieButtonTapped(sender: self)
    }
}
